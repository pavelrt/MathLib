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
