//
//  discretization.swift
//  FRASLib
//
//  Created by Pavel Rytir on 7/25/18.
//

import Foundation

public struct Discretization {
    public init(data: [Double], epsilon: Double) {
        var data = data
        data.sort()
        var newBoundaries = [Double]()
        for val in data {
            if let last = newBoundaries.last, val < last + epsilon {
                // Nothing
            } else {
                newBoundaries.append(val)
            }
        }
        boundaries = newBoundaries
        assert(!boundaries.isEmpty)
    }
    /// Discretization bounds.
    public let boundaries : [Double]
    
    public func findClosestValueAndIndex(to x: Double) -> (boundary: Double, idx: Int) {
        func find(in interval:ClosedRange<Int>) -> (Double, Int) {
            if interval.count == 1 {
                return (boundaries[interval.lowerBound], interval.lowerBound)
            } else {
                let middleIdx = interval.lowerBound + interval.count / 2
                if x < boundaries[middleIdx] {
                    return find(in: interval.lowerBound...middleIdx - 1)
                } else {
                    return find(in: middleIdx...interval.upperBound)
                }
            }
        }
        
        let (boundVal, boundIdx) = find(in: 0...boundaries.count - 1)
        
        if boundaries.count == 1 {
            return (boundVal, boundIdx)
        } else {
            if x < boundVal && boundIdx > 0 {
                if x - boundaries[boundIdx - 1] < boundVal - x {
                    return (boundaries[boundIdx - 1], boundIdx - 1)
                } else {
                    return (boundaries[boundIdx], boundIdx)
                }
            }
            if x > boundVal && boundIdx < boundaries.count - 1 {
                if x - boundVal < boundaries[boundIdx + 1] - x {
                    return (boundaries[boundIdx], boundIdx)
                } else {
                    return (boundaries[boundIdx + 1], boundIdx + 1)
                }
            }
        }
        return (boundaries[boundIdx], boundIdx)
    }
}

