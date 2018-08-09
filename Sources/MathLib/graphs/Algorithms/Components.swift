//
//  Components.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/9/18.
//

import Foundation


extension AbstractDiGraph {
    public func findAllVerticesInTheSameComponent(as vertexId: Int) -> Set<Int> {
        var component = Set<Int>()
        depthFirstSearch(from: vertexId, callback: { _ = component.insert($0.id) })
        return component
    }
}
