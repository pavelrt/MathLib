//
//  simpleGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation

public struct Vertex : AbstractVertex {
    public let id: Int
    public var edges: [Int]
    public var neighbors: [Int]
}

public struct Edge : AbstractEdge {
    public let id: Int
    public var vertices: [Int]
}

public struct Graph : AbstractGraph {
    public typealias V = Vertex
    public typealias E = Edge
    public typealias VertexCollection = [Int:V]
    public typealias EdgeCollection = [Int:E]
    
    public var vertices: [Int : V]
    public var edges: [Int : E]
    
    public var availableVertexId : Int
    public var availableEdgeId : Int
    
    public init() {
        self.vertices = [:]
        self.edges = [:]
        self.availableVertexId = 1
        self.availableEdgeId = 1
    }
    public init<DG: AbstractDiGraph>(diGraph: DG) {
        

        var newEdgesIds = Set<Int>()
        var addedEdges = Set<Tuple<Int>>()
        for (edgeId, edge) in diGraph.diEdges where !addedEdges.contains(Tuple(first: min(edge.start,edge.end), second: max(edge.start,edge.end))) {
            newEdgesIds.insert(edgeId)
            addedEdges.insert(Tuple(first: min(edge.start,edge.end), second: max(edge.start,edge.end)))
        }
        self.vertices = Dictionary(uniqueKeysWithValues: diGraph.diVertices.map { (key: $0.key, value: Vertex(id: $0.value.id, edges: $0.value.edges.filter {newEdgesIds.contains($0)}, neighbors: $0.value.neighbors)) })
        
        self.edges = Dictionary(uniqueKeysWithValues: newEdgesIds.map { (key: $0, value: Edge(id: $0, vertices: diGraph.diEdge($0)!.vertices)) })
        self.availableVertexId = diGraph.newVertexId
        self.availableEdgeId = diGraph.newEdgeId
    }
    
    public func vertex(_ id: Int) -> V? {
        return vertices[id]
    }
    
    public func edge(_ id: Int) -> E? {
        return edges[id]
    }
   
}
