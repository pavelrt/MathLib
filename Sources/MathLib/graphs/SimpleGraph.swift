//
//  simpleGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation

public struct Vertex : AbstractMutableVertex, Codable {
    public let id: Int
    public private(set) var neighbors: [Neighbor]
    public mutating func attachEdge(edgeId: Int, neighborId: Int) {
        neighbors.append(Neighbor(vertexId: neighborId, edgeId: edgeId))
    }
    public mutating func removeEdge(id: Int) {
        neighbors = neighbors.filter {$0.edgeId != id}
    }
    public mutating func filterNeighbors(_ isIncluded: (Neighbor) -> Bool) {
        neighbors = neighbors.filter { isIncluded($0) }
    }
}

public struct Edge : AbstractEdge {
    public let id: Int
    public let vertex1: Int
    public let vertex2: Int
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
        self.vertices = Dictionary(uniqueKeysWithValues: diGraph.diVertices.map { diVertex -> (Int,Vertex) in
            let diVertexId = diVertex.key
            var diEdges = diVertex.value.inEdges
            diEdges.append(contentsOf: diVertex.value.outEdges)
            let neighbors = diEdges.filter {newEdgesIds.contains($0)} .map {diGraph.diEdge($0)!} .map {Neighbor(vertexId: $0.start == diVertexId ? $0.end : $0.start, edgeId: $0.id)}
            return (diVertexId,Vertex(id: diVertexId, neighbors: neighbors))
            })
        
        self.edges = Dictionary(uniqueKeysWithValues: newEdgesIds.map { (key: $0, value: Edge(id: $0, vertex1: diGraph.diEdge($0)!.vertex1, vertex2: diGraph.diEdge($0)!.vertex2)) })
        self.availableVertexId = diGraph.newVertexId
        self.availableEdgeId = diGraph.newEdgeId
    }
    
    public init<G: AbstractGraph>(graph: G, inducedOn verticesIds: Set<Int>) where G.V == V, G.E == E {
        
        let vertices = verticesIds.map {graph.vertex($0)!}
        
        var newEdges = [Int: E]()
        var newVertices = [Int: V]()
        
        for var vertex in vertices {
            vertex.filterNeighbors { verticesIds.contains($0.vertexId) }
            newVertices[vertex.id] = vertex
            for neighbor in vertex.neighbors {
                newEdges[neighbor.edgeId] = graph.edge(neighbor.edgeId)!
            }
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
            newVerticesIds.insert(edge.vertex1)
            newVerticesIds.insert(edge.vertex2)
        }
        
        let vertices = newVerticesIds.map {graph.vertex($0)!}
        
        var newVertices = [Int: V]()
        
        for var vertex in vertices {
            vertex.filterNeighbors { newVerticesIds.contains($0.vertexId) }
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

extension Graph : AbstractMutableGraph {
    public mutating func add(edge: E) {
        var vertex1 = vertex(edge.vertex1)!
        vertex1.attachEdge(edgeId: edge.id, neighborId: edge.vertex2)
        vertices[vertex1.id] = vertex1

        if edge.vertex1 != edge.vertex2 {
            var vertex2 = vertex(edge.vertex2)!
            vertex2.attachEdge(edgeId: edge.id, neighborId: edge.vertex1)
            vertices[vertex2.id] = vertex2
        }
    }
    public mutating func remove(edge: E) {
        var vertex1 = vertex(edge.vertex1)!
        vertex1.removeEdge(id: edge.id)
        vertices[vertex1.id] = vertex1
        if edge.vertex1 != edge.vertex2 {
            var vertex2 = vertex(edge.vertex2)!
            vertex2.removeEdge(id: edge.id)
            vertices[vertex2.id] = vertex2
        }
        edges.removeValue(forKey: edge.id)
    }
}


