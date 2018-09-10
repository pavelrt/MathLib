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
    
    public init<G: AbstractGraph>(graph: G, inducedOn verticesIds: Set<Int>) where G.V == V, G.E == E {
        
        let vertices = verticesIds.map {graph.vertex($0)!}
        
        var newEdges = [Int: E]()
        var newVertices = [Int: V]()
        
        for vertex in vertices {
            var newVertexEdges = [Int]()
            for edgeId in vertex.edges {
                let edge = graph.edge(edgeId)!
                let edgeVertices = Set(edge.vertices)
                if edgeVertices.isSubset(of: verticesIds) {
                    newEdges[edgeId] = edge
                    newVertexEdges.append(edgeId)
                }
            }
            
            let newNeighbors = vertex.neighbors.filter { verticesIds.contains($0) }
            
            var vertex = vertex
            vertex.edges = newVertexEdges
            vertex.neighbors = newNeighbors
            newVertices[vertex.id] = vertex
        }
        
        self.vertices = newVertices
        self.edges = newEdges
        self.availableEdgeId = graph.availableEdgeId
        self.availableVertexId = graph.availableVertexId
    }
    
    public init<G: AbstractGraph>(graph: G, onlyWithEdges edgesIds: Set<Int>) where G.V == V, G.E == E {
        let newEdges = Dictionary(uniqueKeysWithValues: edgesIds.map { (key: $0, value: graph.edge($0)!) })
        
        var newVerticesIds = Set<Int>()
        
        for (_, edge) in newEdges {
            newVerticesIds = newVerticesIds.union(edge.vertices)
        }
        
        let vertices = newVerticesIds.map {graph.vertex($0)!}
        
        var newVertices = [Int: V]()
        
        for vertex in vertices {
            var newVertexEdges = [Int]()
            var newVertexNeigbors = [Int]()
            for edgeId in vertex.edges {
                if let edge = newEdges[edgeId] {
                    newVertexEdges.append(edgeId)
                    let edgeNeighbor = edge.vertices.filter { $0 != vertex.id }
                    newVertexNeigbors.append(contentsOf: edgeNeighbor)
                }
                
            }
            
            //let newNeighbors = vertex.neighbors.filter { newVerticesIds.contains($0) }
            
            var vertex = vertex
            vertex.edges = newVertexEdges
            vertex.neighbors = newVertexNeigbors
            newVertices[vertex.id] = vertex
        }
        self.vertices = newVertices
        self.edges = newEdges
        self.availableEdgeId = graph.availableEdgeId
        self.availableVertexId = graph.availableVertexId
    }
    
    public var numberOfVertices : Int {
        return vertices.count
    }
    
    public var numberOfEdges : Int {
        return edges.count
    }
    
    public func vertex(_ id: Int) -> V? {
        return vertices[id]
    }
    
    public func edge(_ id: Int) -> E? {
        return edges[id]
    }
   
}
