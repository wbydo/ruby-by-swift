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

protocol Parser {
    associatedtype Target
    associatedtype Value
    associatedtype Next
    
    func parse(_ target: Target) -> Result<Value, Next>
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
