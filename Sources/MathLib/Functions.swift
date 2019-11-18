//
//  Functions.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/2/18.
//

import Foundation


public func sigmoid(_ x: Double) -> Double {
    return 1/(1 + exp(-x))
}

public func gcd(a: Int, b:Int) -> Int {
    precondition(a>=0)
    precondition(b>=0)
    return b == 0 ? a : gcd(a: b, b: a % b)
}
