//
//  subgraphs.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/8/18.
//

import Foundation


// FIXME: Everything in this file needs to be retested before any use.

extension AbstractFiniteDiGraph {
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

public struct SubEdgeGraph<G: AbstractFiniteGraph> : AbstractFiniteGraph {
    public typealias V = G.V
    public typealias E = G.E
    public typealias VertexCollection = LazyMapCollection<Set<G.V.Index>, (key: G.V.Index, value: G.V)>
    public typealias EdgeCollection = LazyMapCollection<Set<G.E.Index>, (key: G.E.Index, value: G.E)>
    public typealias NeighborsCollection = [(edge: E, vertex: V)]
    
    public let graph : G
    public let edgeIds : Set<G.E.Index>
    public let verticesIds : Set<G.V.Index>
    
    public init(of graph: G, on edgeIds: Set<G.E.Index>) {
        self.graph = graph
        self.edgeIds = edgeIds
        var vertices = Set<G.V.Index>()
        for edgeId in edgeIds {
            let edge = graph.edge(edgeId)!
            vertices.insert(edge.vertex1Id)
            vertices.insert(edge.vertex2Id)
        }
        self.verticesIds = vertices
    }
    
    public func neighbors(of vertexId: G.E.VertexIndex) -> NeighborsCollection {
        let neighbors = graph.neighbors(of: vertexId).filter { edgeIds.contains($0.edge.id) }
        return neighbors
    }
    
    public func vertex(_ id: G.V.Index) -> G.V? {
        guard verticesIds.contains(id) else {
            return nil
        }
        
        return graph.vertex(id)!
        
//        vertex.filterNeighbors { edgeIds.contains($0.edgeId) }
//
//        return vertex
        //FIXME: Add caching
    }
    
    public func edge(_ id: G.E.Index) -> G.E? {
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
//    public var availableVertexId: Int {
//        return graph.availableVertexId
//    }
//
//    public var availableEdgeId: Int {
//        return graph.availableEdgeId
//    }
    public var numberOfVertices: Int {
        return verticesIds.count
    }
    
    public var numberOfEdges: Int {
        return edgeIds.count
    }
    

    
    
}

public struct InducedSubGraph<G: AbstractFiniteGraph> : AbstractFiniteGraph {
    public typealias V = G.V
    public typealias E = G.E
    public typealias VertexCollection = LazyMapCollection<Set<G.V.Index>, (key: G.V.Index, value: G.V)>
    public typealias EdgeCollection = LazyMapCollection<LazyMapCollection<LazyFilterCollection<LazyMapCollection<G.EdgeCollection, G.E?>>, G.E>, (key: G.E.Index, value: G.E)>
    public typealias NeighborsCollection = [(edge: E, vertex: V)]
    
    
    
    public let graph : G
    public let inducedVerticesIds : Set<V.Index>
    
    public init(of graph: G, on inducedVerticesIds: Set<V.Index>) {
        self.graph = graph
        self.inducedVerticesIds = inducedVerticesIds
    }
    
    public func neighbors(of vertexId: V.Index) -> NeighborsCollection {
        let neighbors = graph.neighbors(of: vertexId).filter { inducedVerticesIds.contains($0.vertex.id) }
        return neighbors
    }
    
    
    public var numberOfVertices: Int {
        return inducedVerticesIds.count
    }
    
    public var numberOfEdges: Int {
        return vertices.count // FIXME: slow!
    }
    
    public func vertex(_ id: G.V.Index) -> G.V? {
        guard inducedVerticesIds.contains(id) else {
            return nil
        }
        return graph.vertex(id)!
        
        //vertex.filterNeighbors { inducedVerticesIds.contains($0.vertexId)}
        
        //return vertex
        //FIXME: Add caching
    }
    
    public func edge(_ id: E.Index) -> E? {
        if let edge = graph.edge(id), inducedVerticesIds.contains(edge.vertex1Id), inducedVerticesIds.contains(edge.vertex2Id) {
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
//    public var availableVertexId: Int {
//        return graph.availableVertexId
//    }
//
//    public var availableEdgeId: Int {
//        return graph.availableEdgeId
//    }
    
    
}

public struct InducedSubDiGraph<G: AbstractFiniteDiGraph> : AbstractFiniteDiGraph {
    public typealias V = G.V
    public typealias E = G.E
    public typealias VertexCollection = LazyMapCollection<Set<V.Index>, (key: V.Index, value: V)>
    public typealias EdgeCollection = LazyMapCollection<LazyMapCollection<LazyFilterCollection<LazyMapCollection<G.EdgeCollection, G.E?>>, G.E>, (key: E.Index, value: G.E)>
    public typealias NeighborsCollection = [(edge: E, vertex: V)]
    
    
    
    public let graph : G
    public let inducedVerticesIds : Set<V.Index>
    
    public init(of graph: G, on inducedVerticesIds: Set<V.Index>) {
        self.graph = graph
        self.inducedVerticesIds = inducedVerticesIds
    }
    
    public func outgoingNeighbors(of vertexId: G.E.VertexIndex) -> NeighborsCollection {
        let neighbors = graph.outgoingNeighbors(of: vertexId).filter {inducedVerticesIds.contains($0.vertex.id)}
        return neighbors
    }
    
    public func incomingNeighbors(of vertexId: G.E.VertexIndex) -> NeighborsCollection {
        let neighbors = graph.incomingNeighbors(of: vertexId).filter {inducedVerticesIds.contains($0.vertex.id)}
        return neighbors
    }
    
    public var numberOfVertices: Int {
        return inducedVerticesIds.count
    }
    
    public var numberOfEdges: Int {
        return diEdges.count // FIXME: Slow
    }
    
    @available(*, deprecated)
    public var verticesCount: Int {
        return numberOfVertices
    }
    
    public func diVertex(_ id: V.Index) -> V? {
        guard inducedVerticesIds.contains(id) else {
            return nil
        }
        return graph.diVertex(id)!
//        vertex.outNeighbors = vertex.outNeighbors.filter {inducedVerticesIds.contains($0)}
//        vertex.inNeighbors = vertex.inNeighbors.filter {inducedVerticesIds.contains($0)}
//        vertex.outEdges = vertex.outEdges.filter { inducedVerticesIds.contains(graph.diEdge($0)!.end) }
//        vertex.inEdges = vertex.inEdges.filter { inducedVerticesIds.contains(graph.diEdge($0)!.start) }
        
        //return vertex
        
        //FIXME: Add caching
    }
    
    public func diEdge(_ id: E.Index) -> E? {
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
//    public var newVertexId: Int {
//        return graph.newVertexId
//    }
//
//    public var newEdgeId: Int {
//        return graph.newEdgeId
//    }
    
}
