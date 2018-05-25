//
//  combinatorics.swift
//  SwiftMath
//
//  Created by Pavel R on 18/05/2018.
//

import Foundation


public func subsets<T: Hashable>(of set: Set<T>, size: Int) -> Set<Set<T>> {
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
    
    let subsetsWithout = subsets(of: setWithoutElement, size: size)
    let subsetsWith = subsets(of: setWithoutElement, size: size - 1)
    
    var returnedSet = Set<Set<T>>()
    for var subset in subsetsWith {
        subset.insert(element)
        returnedSet.insert(subset)
    }
    return returnedSet.union(subsetsWithout)
}
