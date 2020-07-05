//
//  ArrayUtils.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/21/18.
//

import Foundation

/// Subtracts two array
/// - Parameters:
///   - a:
///   - b:
/// - Returns: for all i result[i] = a[i] - b[i]
public func subtractArrays<N:Numeric>(a: [N], b: [N]) -> [N] {
  assert(a.count == b.count)
  var result = [N]()
  result.reserveCapacity(a.count)
  for i in a.indices {
    result.append(a[i] - b[i])
  }
  return result
}


/// Generates all subsets of a
/// - Parameter a:
/// - Returns: Array of all subsets.
public func generateAllSubsets<E>(of a: [E]) -> [[E]] {
  var result = [[E]]()
  result.reserveCapacity(1 << a.count)
  func add(_ t: [E], idx: Int) {
    if idx >= a.count {
      result.append(t)
    } else {
      add(t, idx: idx + 1)
      var t = t
      t.append(a[idx])
      add(t, idx: idx + 1)
    }
  }
  add([], idx: 0)
  return result
}

/// Generates cartesion product of n sets.
/// - Parameter sets: An array of sets. Each set is represented as tuple (set_index, array of elements)
/// - Returns: An array that contains elements. Each element is an array with tuples (set_index, element).
public func generateCartesianProduct<E>(of sets: [(Int,[E])]) ->[[(Int,E)]] {
  var combinations = [[(Int,E)]]()
  func generate(keyIdx: Int, combination: [(Int,E)]) {
    if keyIdx >= sets.count {
      if !combination.isEmpty {
        combinations.append(combination)
      }
    } else {
      if sets[keyIdx].1.isEmpty {
        generate(keyIdx: keyIdx + 1, combination: combination)
      } else {
        for v in sets[keyIdx].1 {
          var newCombination = combination
          newCombination.append((sets[keyIdx].0, v))
          generate(keyIdx: keyIdx + 1, combination: newCombination)
        }
      }
    }
  }
  var initArray = [(Int,E)]()
  initArray.reserveCapacity(sets.count)
  generate(keyIdx: 0, combination: initArray)
  return combinations
}
