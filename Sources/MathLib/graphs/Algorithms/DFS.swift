//
//  DFS.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/8/18.
//

import Foundation

extension AbstractDiGraph {
    public func depthFirstSearch(from startId: Int, callback: (V) -> (), maxDepth : Int? = nil) {
        var lifo = [Int]()
        var visited = Set<Int>()
        var hops = [Int:Int]()
        
        visited.insert(startId)
        lifo.append(startId)
        hops[startId] = 0
        callback(vertices[startId]!)
        
        while let vertexId = lifo.popLast() {
            if hops[vertexId]! < maxDepth ?? Int.max {
                for neigborhId in outgoingNeighborsIds(of: vertexId) where !visited.contains(neigborhId) {
                    visited.insert(neigborhId)
                    lifo.append(neigborhId)
                    hops[neigborhId] = hops[vertexId]! + 1
                    callback(vertices[neigborhId]!)
                }
            }
        }
    }
    
    public var connected: Bool {
        if let startVertex = self.vertices.first?.key {
            var visitedVerticesCnt = 0
            depthFirstSearch(from: startVertex, callback: { _ in visitedVerticesCnt += 1 })
            return visitedVerticesCnt == vertices.count
        } else {
            return true // Empty graph.
        }
    }
    
}
