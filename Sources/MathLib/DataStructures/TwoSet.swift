//
//  TwoSet.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/5/20.
//

import Foundation

/// Set containing exactly two elements. Equality does not depend on the order of elements.
public struct TwoSet<Element: Hashable> : Hashable {
  let e1 : Element
  let e2 : Element
  public init(_ e1: Element, _ e2: Element) {
    self.e1 = e1
    self.e2 = e2
  }
  public static func == (lhs: TwoSet, rhs: TwoSet) -> Bool {
    return (lhs.e1 == rhs.e1 && lhs.e2 == rhs.e2) || (lhs.e1 == rhs.e2 && lhs.e2 == rhs.e1)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(e1.hashValue &+ e2.hashValue) // Needs to be combined commutatively.
  }
}
