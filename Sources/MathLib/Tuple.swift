//
//  Tuple.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/25/18.
//

import Foundation

public struct Tuple<T> {
    public init(_ first: T, _ second: T) {
        self.first = first
        self.second = second
    }
    public var first : T
    public var second : T
}

extension Tuple : Equatable where T : Equatable {

}

extension Tuple : Hashable where T : Hashable {

}

public struct Triple<T> {
    public var first, second, third: T
    public init(_ first: T, _ second: T, _ third: T) {
        self.first = first
        self.second = second
        self.third = third
    }
}

extension Triple : Equatable where T : Equatable {

}

extension Triple : Hashable where T : Hashable {

}

