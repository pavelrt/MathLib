//
//  subgraphs.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/8/18.
//

import Foundation

extension AbstractDiGraph {
//    mutating func induceSubgraph(on newVertices: [Int]) {
//        let newVerticesSet = Set(newVertices)
//        let outEdges = Set(newVertices.flatMap { self.vertex($0)!.outEdges })
//        let inEdges = Set(newVertices.flatMap { self.vertex($0)!.inEdges })
//        let newEdges = outEdges.intersection(inEdges)
//        let newEdgesTuples = newEdges.map { ($0, self.edge($0)!) }
//        edges = Dictionary(uniqueKeysWithValues: newEdgesTuples)
//        
//        let newVerticesTuples = newVertices.map { (vertexId) -> (Int, V) in
//            var vertex = vertices[vertexId]!
//            vertex.outEdges = vertex.outEdges.filter { newEdges.contains($0) }
//            vertex.inEdges = vertex.inEdges.filter { newEdges.contains($0) }
//            vertex.outNeighbors = vertex.outNeighbors.filter { newVerticesSet.contains($0) }
//            vertex.inNeighbors = vertex.inNeighbors.filter { newVerticesSet.contains($0) }
//
//            return (vertexId, vertex)
//        }
//        vertices = Dictionary(uniqueKeysWithValues: newVerticesTuples)
//    }

}

public struct SubEdgeGraph<G: AbstractGraph> : AbstractGraph where G.V : AbstractMutableVertex {
    public typealias V = G.V
    public typealias E = G.E
    public typealias VertexCollection = LazyMapCollection<Set<Int>, (key: Int, value: G.V)>
    public typealias EdgeCollection = LazyMapCollection<Set<Int>, (key: Int, value: G.E)>
    
    public let graph : G
    public let edgeIds : Set<Int>
    public let verticesIds : Set<Int>
    
    public init(of graph: G, on edgeIds: Set<Int>) {
        self.graph = graph
        self.edgeIds = edgeIds
        var vertices = Set<Int>()
        for edgeId in edgeIds {
            let edge = graph.edge(edgeId)!
            vertices.insert(edge.vertex1)
            vertices.insert(edge.vertex2)
        }
        self.verticesIds = vertices
    }
    
    public func vertex(_ id: Int) -> G.V? {
        guard verticesIds.contains(id) else {
            return nil
        }
        var vertex = graph.vertex(id)!
        
        vertex.filterNeighbors { edgeIds.contains($0.edgeId) }
        
        return vertex
        //FIXME: Add caching
    }
    
    public func edge(_ id: Int) -> G.E? {
        if edgeIds.contains(id), let edge = graph.edge(id) {
            return edge
        } else {
            return nil
        }
    }
    
    public var vertices: VertexCollection {
        return verticesIds.lazy.map { (key: $0, value: self.vertex($0)!) }
    }
    
    public var edges: EdgeCollection {
        return edgeIds.lazy.map { (key: $0, value: self.edge($0)!)}
    }
    public var availableVertexId: Int {
        return graph.availableVertexId
    }
    
    public var availableEdgeId: Int {
        return graph.availableEdgeId
    }
    public var numberOfVertices: Int {
        return verticesIds.count
    }
    
    public var numberOfEdges: Int {
        return edgeIds.count
    }
    

    
    
}

public struct InducedSubGraph<G: AbstractGraph> : AbstractGraph where G.V : AbstractMutableVertex {
    
    public typealias VertexCollection = LazyMapCollection<Set<Int>, (key: Int, value: G.V)>
    public typealias EdgeCollection = LazyMapCollection<LazyMapCollection<LazyFilterCollection<LazyMapCollection<G.EdgeCollection, G.E?>>, G.E>, (key: Int, value: G.E)>
    
    public typealias V = G.V
    public typealias E = G.E
    
    public let graph : G
    public let inducedVerticesIds : Set<Int>
    
    public init(of graph: G, on inducedVerticesIds: Set<Int>) {
        self.graph = graph
        self.inducedVerticesIds = inducedVerticesIds
    }
    
    public var numberOfVertices: Int {
        return inducedVerticesIds.count
    }
    
    public var numberOfEdges: Int {
        return vertices.count // FIXME: slow!
    }
    
    public func vertex(_ id: Int) -> G.V? {
        guard inducedVerticesIds.contains(id) else {
            return nil
        }
        var vertex = graph.vertex(id)!
        
        vertex.filterNeighbors { inducedVerticesIds.contains($0.vertexId)}
        
        return vertex
        //FIXME: Add caching
    }
    
    public func edge(_ id: Int) -> G.E? {
        if let edge = graph.edge(id), inducedVerticesIds.contains(edge.vertex1), inducedVerticesIds.contains(edge.vertex2) {
            return edge
        } else {
            return nil
        }
    }
    
    public var vertices: VertexCollection {
        return inducedVerticesIds.lazy.map { (key: $0, value: self.vertex($0)!) }
    }
    
    public var edges: EdgeCollection {
        return graph.edges.lazy.compactMap { self.edge($0.key) } .map { (key: $0.id, value: $0) }
    }
    public var availableVertexId: Int {
        return graph.availableVertexId
    }
    
    public var availableEdgeId: Int {
        return graph.availableEdgeId
    }
    
    
}

public struct InducedSubDiGraph<G: AbstractDiGraph> : AbstractDiGraph {
    public typealias VertexCollection = LazyMapCollection<Set<Int>, (key: Int, value: G.V)>
    public typealias EdgeCollection = LazyMapCollection<LazyMapCollection<LazyFilterCollection<LazyMapCollection<G.EdgeCollection, G.E?>>, G.E>, (key: Int, value: G.E)>
    
    public typealias V = G.V
    public typealias E = G.E
    
    public let graph : G
    public let inducedVerticesIds : Set<Int>
    
    public init(of graph: G, on inducedVerticesIds: Set<Int>) {
        self.graph = graph
        self.inducedVerticesIds = inducedVerticesIds
    }
    
    public var verticesCount: Int {
        return inducedVerticesIds.count
    }
    
    public func diVertex(_ id: Int) -> G.V? {
        guard inducedVerticesIds.contains(id) else {
            return nil
        }
        var vertex = graph.diVertex(id)!
        vertex.outNeighbors = vertex.outNeighbors.filter {inducedVerticesIds.contains($0)}
        vertex.inNeighbors = vertex.inNeighbors.filter {inducedVerticesIds.contains($0)}
        vertex.outEdges = vertex.outEdges.filter { inducedVerticesIds.contains(graph.diEdge($0)!.end) }
        vertex.inEdges = vertex.inEdges.filter { inducedVerticesIds.contains(graph.diEdge($0)!.start) }
        
        return vertex
        
        //FIXME: Add caching
    }
    
    public func diEdge(_ id: Int) -> G.E? {
        if let edge = graph.diEdge(id), inducedVerticesIds.contains(edge.start), inducedVerticesIds.contains(edge.end) {
            return edge
        } else {
            return nil
        }
    }
    

    
    public var diVertices: VertexCollection {
        return inducedVerticesIds.lazy.map { (key: $0, value: self.diVertex($0)!) }
    }
    
    public var diEdges: EdgeCollection {
        return graph.diEdges.lazy.compactMap { self.diEdge($0.key) } .map { (key: $0.id, value: $0) }
    }
    public var newVertexId: Int {
        return graph.newVertexId
    }
    
    public var newEdgeId: Int {
        return graph.newEdgeId
    }
    
}
