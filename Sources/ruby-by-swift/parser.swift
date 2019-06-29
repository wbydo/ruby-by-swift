//
//  parser.swift
//  ruby-by-swift
//
//  Created by wbydo on 2019/06/17.
//

import Foundation

enum ParseResult<V, N> {
    case success(Success);
    case failure(Failure);
    case initial(Initial)
    case eos
    
    struct Success {
        let value: V;
        let next: N?;
    }
    
    struct Failure {
        let next: N?;
    }
    
    struct Initial {
        let next: N
    }
    
    static func success(value: V, next: N?) -> ParseResult {
        return .success(Success(value: value, next: next));
    }
    
    static func failure(next: N?) -> ParseResult {
        return .failure(Failure(next: next))
    }
    
    static func initial(next: N) -> ParseResult {
        return .initial(Initial(next: next))
    }
}

extension ParseResult.Success where N == String {
    init?(value: V, next: N) {
        guard !next.isEmpty else {
            return nil
        }
        self.value = value
        self.next = next
    }
}

struct MutationResult<S, V, N> {
    let state: S
    let result: ParseResult<V, N>
}

struct State<S, V, N> {
    let mutator: (S) -> MutationResult<S, V, N>
    
    func then<V1>(_ nextAction: @escaping (ParseResult<V, N>) -> State<S, V1, N>) -> State<S, V1, N> {
        let mutator = {(prevState: S) -> MutationResult<S, V1, N> in
            let mutationResult = self.mutator(prevState)
            let parseResult = mutationResult.result
            let nextState = nextAction(parseResult)
            return nextState.mutator(mutationResult.state)
        }
        return State<S, V1, N>(mutator: mutator)
    }
    
    func then<P: Parser>(_ parser: P) -> State<S, P.Value, P.Next> where N == P.Target, N == P.Next, S == [P.Value], V == P.Value {
        let nextAction = {(prevResult: ParseResult<V, N>) -> State<S, P.Value, P.Next> in
            switch prevResult {
            case let .initial(i):
                let mutator = {(_: S) -> MutationResult<S, P.Value, P.Next> in
                    let parseResult = parser.parse(i.next)
                    return MutationResult<S, P.Value, P.Next>(state: [], result: parseResult)
                }
                return State<S, P.Value, P.Next>(mutator: mutator)
                
            case let .success(s):
                let mutator = {(state: S) -> MutationResult<S, P.Value, P.Next> in
                    if let next = s.next {
                        let parseResult = parser.parse(next)
                        return MutationResult<S, P.Value, P.Next>(state: state + [s.value], result: parseResult)
                    } else {
                        return MutationResult<S, P.Value, P.Next>(state: state + [s.value], result: ParseResult.eos)
                    }
                    
                }
                return State<S, P.Value, P.Next>(mutator: mutator)
                
            case .failure:
                let mutator = {(state: S) -> MutationResult<S, P.Value, P.Next> in
                    return MutationResult<S, P.Value, P.Next>(state: state, result: prevResult)
                }
                return State<S, P.Value, P.Next>(mutator: mutator)
                
            case .eos:
                let mutator = {(state: S) -> MutationResult<S, P.Value, P.Next> in
                    let parseResult = ParseResult<P.Value, P.Next>.failure(next: nil)
                    return MutationResult<S, P.Value, P.Next>(state: state, result: parseResult)
                }
                return State<S, P.Value, P.Next>(mutator: mutator)
                
            }
        }
        return self.then(nextAction)
    }
    
    static func create<T>(_ value: N) -> State where S == [T] {
        let mutator = {(_: [T]) -> MutationResult<[T], V, N> in
            let result = ParseResult<V, N>.initial(next: value)
            return MutationResult(state: [], result: result)
        }
        return State<S, V, N>(mutator: mutator)
    }

    static func create<V1, N1>(_ parseReuslt: ParseResult<V1, N1>) -> State<S, V1, N1> {
        let mutator = {(initialState: S) -> MutationResult<S, V1, N1> in
            return MutationResult(state: initialState, result: parseReuslt)
        }
        return State<S, V1, N1>(mutator: mutator)
    }
}

protocol Parser {
    associatedtype Target
    associatedtype Value
    associatedtype Next
    
    func parse(_ target: Target) -> ParseResult<Value, Next>
}

struct OrParser<LP: Parser, RP: Parser>: Parser
        where LP.Target == RP.Target, LP.Value == RP.Value, LP.Next == RP.Next {

    let lhs: LP
    let rhs: RP
    
    func parse(_ target: LP.Target) -> ParseResult<LP.Value, LP.Next> {
        let lresult = lhs.parse(target)
        guard case .failure = lresult else {
            return lresult;
        }
        
        let rresult = rhs.parse(target)
        return rresult;
        
    }
}

extension Parser {
    func or<P: Parser>(_ other: P) -> OrParser<Self, P> {
        return OrParser(lhs: self, rhs: other);
    }
}

struct AnyChar: Parser {
    func parse(_ target: String) -> ParseResult<Character, String> {
        guard !target.isEmpty else {
            return ParseResult.failure(next: nil)
        }
        
        let startIndex = target.startIndex;
        
        let value = target[startIndex];
        let next = target[target.index(startIndex, offsetBy: 1)..<target.endIndex]
        
        if next.isEmpty {
            return ParseResult.success(value: value, next: nil);
        } else {
            return ParseResult.success(value: value, next: String(next));
        }
    }
}

struct SpecificChar: Parser {
    let value: Character

    func parse(_ target: String) -> ParseResult<Character, String> {
        let anyChar = AnyChar();
        let result = anyChar.parse(target);
        
        guard case let .success(s) = result else {
            return result;
        }
        
        if s.value == self.value {
            return result
        } else {
            return ParseResult.failure(next: target);
        }
    }
}
