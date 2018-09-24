//
//  DFS.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/8/18.
//

import Foundation

extension AbstractDiGraph {
    public func depthFirstSearch(from startId: V.Index, callback: (V) -> (), maxDepth : Int? = nil) {
        var lifo = [V.Index]()
        var visited = Set<V.Index>()
        var hops = [V.Index:Int]()
        
        visited.insert(startId)
        lifo.append(startId)
        hops[startId] = 0
        callback(diVertex(startId)!)
        
        while let topVertexId = lifo.popLast() {
            //let topVertex = diVertex(vertexId)!
            if hops[topVertexId]! < maxDepth ?? Int.max {
                for neigborhEdgeVertex in outgoingNeighbors(of: topVertexId) where !visited.contains(neigborhEdgeVertex.vertex.id) {
                    let neighborhId = neigborhEdgeVertex.vertex.id
                    visited.insert(neighborhId)
                    lifo.append(neighborhId)
                    hops[neighborhId] = hops[topVertexId]! + 1
                    callback(neigborhEdgeVertex.vertex)
                }
            }
        }
    }
}

extension AbstractFiniteDiGraph {
    
    public var connected: Bool {
        if let startVertex = self.diVertices.first?.key {
            var visitedVerticesCnt = 0
            depthFirstSearch(from: startVertex, callback: { _ in visitedVerticesCnt += 1 })
            return visitedVerticesCnt == self.numberOfVertices
        } else {
            return true // Empty graph.
        }
    }
    
}
