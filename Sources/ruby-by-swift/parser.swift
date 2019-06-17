//
//  parser.swift
//  ruby-by-swift
//
//  Created by hbk on 2019/06/17.
//

import Foundation

struct Result<V, N> {
    let value: V
    let next: N
}

struct AnyChar {
    func parse(_ target: String) -> Result<Character, String> {
        let startIndex = target.startIndex;
        
        let value = target[startIndex];
        let next = target[target.index(startIndex, offsetBy: 1)..<target.endIndex]
        
        return Result(value: value, next: String(next));
    }
}
