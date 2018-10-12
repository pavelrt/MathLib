//
//  ArrayUtils.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/21/18.
//

import Foundation

public func subtractArrays<N:Numeric>(a: [N], b: [N]) -> [N] {
    assert(a.count == b.count)
    var result = [N]()
    result.reserveCapacity(a.count)
    for i in a.indices {
        result.append(a[i] - b[i])
    }
    return result
}


public func allSubsets<E>(of a: [E]) -> [[E]] {
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

public func cartesianProduct<E>(of actions: [(Int,[E])]) ->[[(Int,E)]] {
    //print(actions)
    var combinations = [[(Int,E)]]()
    //let keys = Array(actions.keys)
    func generate(keyIdx: Int, combination: [(Int,E)]) {
        if keyIdx >= actions.count {
            if !combination.isEmpty {
                combinations.append(combination)
            }
        } else {
            if actions[keyIdx].1.isEmpty {
                generate(keyIdx: keyIdx + 1, combination: combination)
            } else {
                for v in actions[keyIdx].1 {
                    var newCombination = combination
                    newCombination.append((actions[keyIdx].0, v))
                    generate(keyIdx: keyIdx + 1, combination: newCombination)
                }
            }
        }
    }
    var initArray = [(Int,E)]()
    initArray.reserveCapacity(actions.count)
    generate(keyIdx: 0, combination: initArray)
    //print("combs")
    //print(combinations)
    return combinations
}
