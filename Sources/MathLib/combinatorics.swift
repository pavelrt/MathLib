//
//  combinatorics.swift
//  SwiftMath
//
//  Created by Pavel R on 18/05/2018.
//

import Foundation


/// Generates all k-element subsets of a given set.
/// - Parameters:
///   - set: Set
///   - size: size of subsets.
/// - Returns: All k-elements subsets.
public func generateAllSubsets<T: Hashable>(of set: Set<T>, size: Int) -> Set<Set<T>> {
  // FIXME: Write tests for this function. It probably contains a bug.
  if size == 0 {
    return [Set<T>()]
  }
  if size > set.count {
    return []
  }
  if size == set.count {
    return [set]
  }
  
  let element = set.first!
  var setWithoutElement = set
  setWithoutElement.remove(element)
  
  let subsetsWithout = generateAllSubsets(of: setWithoutElement, size: size)
  let subsetsWith = generateAllSubsets(of: setWithoutElement, size: size - 1)
  
  var returnedSet = Set<Set<T>>()
  for var subset in subsetsWith {
    subset.insert(element)
    returnedSet.insert(subset)
  }
  return returnedSet.union(subsetsWithout)
}
