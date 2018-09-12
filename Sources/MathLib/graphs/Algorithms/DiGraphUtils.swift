//
//  DiGraphUtils.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/12/18.
//

import Foundation


extension AbstractDiGraph {
    public var isSymmetric : Bool {
        for (_,diEdge) in diEdges {
            if findEdge(from: diEdge.end, to: diEdge.start).isEmpty {
                return false
            }
        }
        return true
    }
}
