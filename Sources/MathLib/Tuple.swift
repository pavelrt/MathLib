//
//  Tuple.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/25/18.
//

import Foundation

public struct Tuple<T> {
    public init(first: T, second: T) {
        self.first = first
        self.second = second
    }
    var first : T
    var second : T
}

extension Tuple : Equatable where T : Equatable {
    public static func == (lhs: Tuple<T>, rhs: Tuple<T>) -> Bool {
        return lhs.first == rhs.first && lhs.second == rhs.second
    }
}

extension Tuple : Hashable where T : Hashable {
    public var hashValue: Int {
        return first.combineHashValue(with: second.hashValue)
    }
}

