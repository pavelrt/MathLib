//
//  abstractDiGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation

public struct AbstractDiVertex : DiVertex {
    public init(id: Int) {
        self.id = id
        self.outEdges = []
        self.inEdges = []
    }
    public let id: Int
    public var outEdges: [Int]
    public var inEdges: [Int]
}

public struct AbstractDiEdge : DiEdge{
    public init(id: Int, start from: Int, end to: Int) {
        self.start = from
        self.end = to
        self.id = id
    }
    public var id: Int
    public var start: Int
    public var end: Int
}


extension DiGraph where DiGraph.V == AbstractDiVertex, DiGraph.E == AbstractDiEdge {
    public mutating func addNewVertex() -> V {
        let vertexId = self.newVertexId
        self.newVertexId += 1
        let newVertex = V(id: vertexId)
        self.add(vertex: newVertex)
        return newVertex
    }
    public mutating func addEdge(from startId: Int, to endId: Int) -> E {
        let edgeId = self.newEdgeId
        self.newEdgeId += 1
        let newEdge = E(id: edgeId, start: startId, end: endId)
        self.edges[edgeId] = newEdge
        var start = self.vertices[startId]!
        var end = self.vertices[endId]!
        start.outEdges.append(edgeId)
        end.inEdges.append(edgeId)
        self.vertices[startId] = start
        self.vertices[endId] = end
        return newEdge
    }
}
