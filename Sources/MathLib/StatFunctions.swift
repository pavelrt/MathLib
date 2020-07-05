//
//  StatFunctions.swift
//  MathLib
//
//  Created by Pavel Rytir on 01/11/2018.
//

import Foundation


extension Array where Element == Double {
  public var avg : Double? {
    guard !isEmpty else {
      return nil
    }
    let sum = self.reduce(0.0, + )
    return sum / Double(count)
  }
  public var variance : Double? {
    guard !isEmpty else {
      return nil
    }
    let sumSquares = reduce(0.0) { $0 + pow($1, 2) }
    return sumSquares / Double(count) - pow(avg!, 2)
  }
}
