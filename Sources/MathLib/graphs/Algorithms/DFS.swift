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
        callback(diVertex(startId)!)
        
        while let vertexId = lifo.popLast() {
            let topVertex = diVertex(vertexId)!
            if hops[vertexId]! < maxDepth ?? Int.max {
                for neigborhId in topVertex.outNeighbors where !visited.contains(neigborhId) {
                    visited.insert(neigborhId)
                    lifo.append(neigborhId)
                    hops[neigborhId] = hops[vertexId]! + 1
                    callback(diVertex(neigborhId)!)
                }
            }
        }
    }
    
    public var connected: Bool {
        if let startVertex = self.diVertices.first?.key {
            var visitedVerticesCnt = 0
            depthFirstSearch(from: startVertex, callback: { _ in visitedVerticesCnt += 1 })
            return visitedVerticesCnt == verticesCount
        } else {
            return true // Empty graph.
        }
    }
    
}
