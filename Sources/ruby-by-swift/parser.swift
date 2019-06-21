//
//  parser.swift
//  ruby-by-swift
//
//  Created by wbydo on 2019/06/17.
//

import Foundation

enum Result<V, N> {
    case success(Success);
    case failure(Failure);
    
    struct Success {
        let value: V;
        let next: N;
    }
    
    struct Failure {
        let next: N;
    }
    
    static func success(value: V, next: N) -> Result {
        return .success(Success(value: value, next: next));
    }
    
    static func failure(next: N) -> Result {
        return .failure(Failure(next: next))
    }
}

extension Result.Success where N == String {
    init?(value: V, next: N) {
        guard !next.isEmpty else {
            return nil
        }
        self.value = value
        self.next = next
    }
}

struct State<V, N> {
    let mutator: (State) -> Result<V, N>
    
    struct DoNothingParser<T> {
        func parse(_ target: T) -> Result<T?, T> {
            return Result.success(value: nil, next: target)
        }
    }
    
    func then<P: Parser>(parser: P) -> State<(V, P.Value), N>
            where N == P.Target, N == P.Next {

        let computedMutator = {(prevState: State) -> Result<(V, P.Value), N> in
            
            let prevResult: Result<V, N> = self.mutator(prevState)
        
            if case let .failure(f1) = prevResult {
                return Result.failure(next: f1.next)
            }
            
            if case let .success(s1) = prevResult {
                let prevValue: V = s1.value
                let prevNext: N = s1.next
                let nextResult: Result<P.Value, P.Next> = parser.parse(prevNext)
                
                
                if case let .failure(f2) = nextResult {
                    return Result.failure(next: f2.next)
                }
                
                if case let .success(s2) = nextResult {
                    return Result.success(value: (prevValue, s2.value), next: s2.next)
                }
                
                fatalError()
            }
            
            fatalError()
        }
        
        return State<(V, P.Value), N>(mutator: computedMutator)
    }
}

protocol Parser {
    associatedtype Target
    associatedtype Value
    associatedtype Next
    
    func parse(_ target: Target) -> Result<Value, Next>
}

struct DoNothingParser<T>: Parser {
    func parse(_ target: T) -> Result<T?, T> {
        return Result.success(value: nil, next: target)
    }
}

struct OrParser<LP: Parser, RP: Parser>: Parser
        where LP.Target == RP.Target, LP.Value == RP.Value, LP.Next == RP.Next {

    let lhs: LP
    let rhs: RP
    
    func parse(_ target: LP.Target) -> Result<LP.Value, LP.Next> {
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
    func parse(_ target: String) -> Result<Character, String?> {
        guard !target.isEmpty else {
            return Result.failure(next: nil)
        }
        
        let startIndex = target.startIndex;
        
        let value = target[startIndex];
        let next = target[target.index(startIndex, offsetBy: 1)..<target.endIndex]
        
        if next.isEmpty {
            return Result.success(value: value, next: nil);
        } else {
            return Result.success(value: value, next: String(next));
        }
    }
}

struct SpecificChar: Parser {
    let value: Character

    func parse(_ target: String) -> Result<Character, String?> {
        let anyChar = AnyChar();
        let result = anyChar.parse(target);
        
        guard case let .success(s) = result else {
            return result;
        }
        
        if s.value == self.value {
            return result
        } else {
            return Result.failure(next: target);
        }
    }
}
