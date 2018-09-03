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
