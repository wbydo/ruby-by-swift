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
    
    struct Success {
        let value: V;
        let next: N;
    }
    
    struct Failure {
        let next: N;
    }
    
    static func success(value: V, next: N) -> ParseResult {
        return .success(Success(value: value, next: next));
    }
    
    static func failure(next: N) -> ParseResult {
        return .failure(Failure(next: next))
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

struct State {
    struct MutationResult {
        let state: State
        
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
    func parse(_ target: String) -> ParseResult<Character, String?> {
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

    func parse(_ target: String) -> ParseResult<Character, String?> {
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
