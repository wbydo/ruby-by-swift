//
//  parser.swift
//  ruby-by-swift
//
//  Created by hbk on 2019/06/17.
//

import Foundation

struct Success<V, N> {
    let value: V;
    let next: N;
}

struct Failure<N> {
    let next: N;
}

enum Result<V, SN, FN> {
    case success(Success<V, SN>);
    case failure(Failure<FN>);
}

struct AnyChar {
    func parse(_ target: String) -> Result<Character, String, String?> {
        guard !target.isEmpty else {
            return Result.failure(Failure(next: nil))
        }
        
        let startIndex = target.startIndex;
        
        let value = target[startIndex];
        let next = target[target.index(startIndex, offsetBy: 1)..<target.endIndex]
        
        return Result.success(Success(value: value, next: String(next)));
    }
}

struct SpecificChar {
    let value: Character

    func parse(_ target: String) -> Result<Character, String, String?> {
        let anyChar = AnyChar();
        let result = anyChar.parse(target);
        
        guard case let .success(s) = result else {
            return result;
        }
        
        if s.value == self.value {
            return result
        } else {
            return Result.failure(Failure(next: target))
        }
    }
}
