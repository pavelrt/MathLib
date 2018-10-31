//
//  abstractDiGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation

public struct DiGraph<V: AbstractVertex, E: AbstractDiEdge> : AbstractFiniteDiGraph where V.Index == E.VertexIndex {
    public typealias VertexCollection = [V.Index:V]
    public typealias EdgeCollection = [E.Index:E]
    public typealias NeighborsCollection = [(edge: E, vertex: V)]
    public typealias NeighborsIdCollection = [(edgeId: E.Index, vertexId: V.Index)]

    
    public private(set) var diVertices: VertexCollection
    public private(set) var diEdges: EdgeCollection
    private var outgoingNeighbors : [V.Index: [NeighborTuple<V.Index,E.Index>]]
    private var incomingNeighbors : [V.Index: [NeighborTuple<V.Index,E.Index>]]
    
    public init() {
        self.diVertices = [:]
        self.diEdges = [:]
        self.outgoingNeighbors = [:]
        self.incomingNeighbors = [:]
    }
    
    public func outgoingNeighbors(of vertexId: E.VertexIndex) -> NeighborsCollection {
        let vertexOutgoingNeighborsIds = outgoingNeighbors[vertexId] ?? []
        let vertexOutgoingNeighbors = vertexOutgoingNeighborsIds.map {(edge: diEdge($0.edgeId)!, vertex: diVertex($0.vertexId)!)}
        return vertexOutgoingNeighbors
    }
    
    public func outgoingNeighborsId(of vertexId: E.VertexIndex) -> NeighborsIdCollection {
        let vertexOutgoingNeighborsIds = outgoingNeighbors[vertexId] ?? []
        let vertexOutgoingNeighborsIds2 = vertexOutgoingNeighborsIds.map {(edgeId: $0.edgeId, vertexId: $0.vertexId)}
        return vertexOutgoingNeighborsIds2
    }
    
    public func incomingNeighbors(of vertexId: E.VertexIndex) -> NeighborsCollection {
        let vertexIncomingNeighborsIds = incomingNeighbors[vertexId] ?? []
        let vertexIncomingNeighbors = vertexIncomingNeighborsIds.map {(edge: diEdge($0.edgeId)!, vertex: diVertex($0.vertexId)!)}
        return vertexIncomingNeighbors
    }
    
    public func incomingNeighborsId(of vertexId: E.VertexIndex) -> NeighborsIdCollection {
        let vertexIncomingNeighborsIds = incomingNeighbors[vertexId] ?? []
        let vertexIncomingNeighborsIds2 = vertexIncomingNeighborsIds.map {(edgeId: $0.edgeId, vertexId: $0.vertexId)}
        return vertexIncomingNeighborsIds2
    }
    
    public var numberOfVertices: Int {
        return diVertices.count
    }
    
    public var numberOfEdges: Int {
        return diEdges.count
    }
    
    @available(*, deprecated)
    public var verticesCount: Int {
        return numberOfVertices
    }
    
    
    public func diVertex(_ id: V.Index) -> V? {
        return diVertices[id]
    }
    
    public func diEdge(_ id: E.Index) -> E? {
        return diEdges[id]
    }
}

extension DiGraph : AbstractMutableDiGraph {
    mutating public func add(edge: E) {
        guard diEdges[edge.id] == nil else {
            fatalError("Graph already contains an edge with the same id.")
        }
        attachOutgoingEdge(to: edge.start, edgeId: edge.id, neighborId: edge.end)
        attachIncomingEdge(to: edge.end, edgeId: edge.id, neighborId: edge.start)
        diEdges[edge.id] = edge
    }
    
    public mutating func add(vertex: V) {
        guard diVertices[vertex.id] == nil else {
            fatalError("Graph already contains a vertex with the same id.")
        }
        diVertices[vertex.id] = vertex
    }
    
    public mutating func remove(edge: E) {
        assert(diEdges[edge.id] != nil, "Removing non-existing edge.")
        removeOutgoingEdge(from: edge.start, edgeId: edge.id)
        removeIncomingEdge(from: edge.end, edgeId: edge.id)
        diEdges.removeValue(forKey: edge.id)
    }
    
    public mutating func remove(vertex: V) {
        assert(diVertices[vertex.id] != nil, "Removing non-existing vertex.")
        let vertexOutgoingNeighbors = outgoingNeighbors(of: vertex.id)
        for neighbor in vertexOutgoingNeighbors {
            remove(edge: neighbor.edge)
        }
        let vertexIncomingNeighbors = incomingNeighbors(of: vertex.id)
        for neighbor in vertexIncomingNeighbors {
            remove(edge: neighbor.edge)
        }
        diVertices.removeValue(forKey: vertex.id)
        outgoingNeighbors.removeValue(forKey: vertex.id)
        incomingNeighbors.removeValue(forKey: vertex.id)
    }
    
    public mutating func update(edge: E) {
        guard let oldEdge = diEdge(edge.id) else {
            fatalError("Updating non-existing edge.")
        }
        if oldEdge.start == edge.start && oldEdge.end == edge.end {
            diEdges[edge.id] = edge
        } else {
            remove(edge: oldEdge)
            add(edge: edge)
        }
    }
    
    public mutating func update(vertex: V) {
        guard diVertex(vertex.id) != nil else {
            fatalError("Updating non-existing vertex.")
        }
        diVertices[vertex.id] = vertex
    }
}

extension DiGraph {
    private mutating func attachOutgoingEdge(to vertexId: V.Index, edgeId: E.Index, neighborId: V.Index) {
        var vertexOutgoingNeighbors = outgoingNeighbors[vertexId] ?? []
        vertexOutgoingNeighbors.append(NeighborTuple(vertexId: neighborId, edgeId: edgeId))
        outgoingNeighbors[vertexId] = vertexOutgoingNeighbors
    }
    private mutating func attachIncomingEdge(to vertexId: V.Index, edgeId: E.Index, neighborId: V.Index) {
        var vertexIncomingNeighbors = incomingNeighbors[vertexId] ?? []
        vertexIncomingNeighbors.append(NeighborTuple(vertexId: neighborId, edgeId: edgeId))
        incomingNeighbors[vertexId] = vertexIncomingNeighbors
    }
    private mutating func removeOutgoingEdge(from vertexId: V.Index, edgeId: E.Index) {
        let vertexOutgoingNeighbors = outgoingNeighbors[vertexId]!.filter {$0.edgeId != edgeId}
        outgoingNeighbors[vertexId] = vertexOutgoingNeighbors
    }
    private mutating func removeIncomingEdge(from vertexId: V.Index, edgeId: E.Index) {
        let vertexIncomingNeighbors = incomingNeighbors[vertexId]!.filter {$0.edgeId != edgeId}
        incomingNeighbors[vertexId] = vertexIncomingNeighbors
    }
}

extension DiGraph: Equatable where V: Equatable, E: Equatable {
    
}

extension DiGraph : Hashable where V: Hashable, E:Hashable {
    
}

extension DiGraph : Codable where V: Codable, E: Codable, V.Index : Codable, E.Index: Codable {
    
}


public struct IntDiEdge : AbstractDiEdge {
    public typealias Index = Int
    public typealias VertexIndex = Int
    public init(id: Index, start from: VertexIndex, end to: VertexIndex) {
        self.start = from
        self.end = to
        self.id = id
    }
    public var id: Index
    public var start: VertexIndex
    public var end: VertexIndex
}

public typealias IntDiGraph = DiGraph<IntVertex,IntDiEdge>

extension DiGraph {
    
    public init<G: AbstractFiniteDiGraph>(graph: G) where G.V == V, G.E == E {
        //let origGraphVertices = Array(graph.diVertices)
        
        self.diVertices = Dictionary(uniqueKeysWithValues: Array(graph.diVertices)) // FIXME: Remove Array
        self.diEdges = Dictionary(uniqueKeysWithValues: Array(graph.diEdges)) // FIXME: Remove Array
        self.outgoingNeighbors = [:]
        self.incomingNeighbors = [:]
        
        for (vertexId, _) in diVertices {
            self.outgoingNeighbors[vertexId] = graph.outgoingNeighbors(of: vertexId).map {NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)}
            self.incomingNeighbors[vertexId] = graph.incomingNeighbors(of: vertexId).map {NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)}
        }
        
        
        //let newVertices = Array(graph.diVertices) // FIXME:
        //self.diVertices = Dictionary<Int,V>(uniqueKeysWithValues: newVertices)
        //let newEdges = Array(graph.diEdges) // FIXME:
        //self.diEdges = Dictionary(uniqueKeysWithValues: newEdges)
        //self.newEdgeId = graph.newEdgeId
        //self.newVertexId = graph.newVertexId
    }
//    public init(diVertices: [Int : V], diEdges: [Int : E] ,newEdgeId : Int, newVertexId : Int) {
//        self.diVertices = diVertices
//        self.diEdges = diEdges
//        self.newVertexId = newVertexId
//        self.newEdgeId = newEdgeId
//    }
    
    public init(isolatedVertices diVertices: [V]) {
        self.diVertices = Dictionary(uniqueKeysWithValues: diVertices.map {($0.id, $0)})
        self.diEdges = [:]
        self.outgoingNeighbors = [:]
        self.incomingNeighbors = [:]
        
//        self.diVertices = [:]
//        self.diVertices.reserveCapacity(diVertices.count)
//        self.diEdges = [:]
//        self.newEdgeId = 1
//        self.newVertexId = 1
//        for var vertex in diVertices {
//            vertex.inEdges = []
//            vertex.inNeighbors = []
//            vertex.outEdges = []
//            vertex.outNeighbors = []
//            self.diVertices[vertex.id] = vertex
//            self.newVertexId = max(self.newVertexId, vertex.id + 1)
//        }
    }
    
    
    
    public init<G: AbstractFiniteDiGraph>(graph: G, onlyWithEdges edgesIds: Set<E.Index>, keepAllVertices : Bool) where G.V == V, G.E == E {
        
        self.diEdges = Dictionary(uniqueKeysWithValues: edgesIds.map { (key: $0, value: graph.diEdge($0)!) })
        
        let newVerticesIds : Set<V.Index>
        if keepAllVertices {
            newVerticesIds = Set(graph.diVertices.map {$0.key})
        } else {
            var verticesIds = Set<V.Index>()
            for (_, edge) in diEdges {
                verticesIds.insert(edge.start)
                verticesIds.insert(edge.end)
            }
            newVerticesIds = verticesIds
        }
        
        
        self.diVertices = Dictionary(uniqueKeysWithValues: newVerticesIds.map { ($0, graph.diVertex($0)!) })
        self.outgoingNeighbors = [:]
        self.incomingNeighbors = [:]
        
        for (vertexId, _) in diVertices {
            let vertexOutgoingNeighbors = graph.outgoingNeighbors(of: vertexId).filter {edgesIds.contains($0.edge.id)}
            outgoingNeighbors[vertexId] = vertexOutgoingNeighbors.map { NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id) }
            let vertexIncomingNeighbors = graph.incomingNeighbors(of: vertexId).filter {edgesIds.contains($0.edge.id)}
            incomingNeighbors[vertexId] = vertexIncomingNeighbors.map { NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id) }
        }
        
        
        
//        let newDiEdges = Dictionary(uniqueKeysWithValues: edgesIds.map { (key: $0, value: graph.diEdge($0)!) })
//
//        let newVerticesIds : Set<Int>
//        if keepAllVertices {
//            newVerticesIds = Set(graph.diVertices.map {$0.key})
//        } else {
//            var verticesIds = Set<Int>()
//            for (_, edge) in newDiEdges {
//                verticesIds.insert(edge.start)
//                verticesIds.insert(edge.end)
//            }
//            newVerticesIds = verticesIds
//        }
//
//        let diVertices = newVerticesIds.map {graph.diVertex($0)!}
//
//        var newDiVertices = [Int: V]()
//
//        for var diVertex in diVertices {
//            diVertex.outEdges = diVertex.outEdges.filter {edgesIds.contains($0)}
//            diVertex.inEdges = diVertex.inEdges.filter {edgesIds.contains($0)}
//            diVertex.outNeighbors = diVertex.outEdges.map { graph.diEdge($0)!.end }
//            diVertex.inNeighbors = diVertex.inEdges.map { graph.diEdge($0)!.start }
//            newDiVertices[diVertex.id] = diVertex
//        }
//
//        self.diVertices = newDiVertices
//        self.diEdges = newDiEdges
//        self.newEdgeId = graph.newEdgeId
//        self.newVertexId = graph.newVertexId
    }

    
    // FIXME: Write a test.
    public init<G: AbstractFiniteDiGraph>(graph: G, inducedOn verticesIds: Set<V.Index>) where G.V == V, G.E == E {
        
        self.diVertices = Dictionary(uniqueKeysWithValues: verticesIds.map { (vertexId: V.Index) -> (V.Index,V) in
            let vertex = graph.diVertex(vertexId)!
            return (vertex.id, vertex)
        })
        self.outgoingNeighbors = [:]
        self.outgoingNeighbors.reserveCapacity(verticesIds.count)
        self.incomingNeighbors = [:]
        self.incomingNeighbors.reserveCapacity(verticesIds.count)
        
        self.diEdges = [E.Index: E]()
        
        for (vertexId, _) in diVertices {
            let outgoing = graph.outgoingNeighbors(of: vertexId)
            let vertexOutgoingNeighbors = outgoing.filter { verticesIds.contains($0.vertex.id) }
            for neighbor in vertexOutgoingNeighbors where diEdges[neighbor.edge.id] == nil {
                diEdges[neighbor.edge.id] = neighbor.edge
            }
            outgoingNeighbors[vertexId] = vertexOutgoingNeighbors.map { NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id) }
            
            let incoming = graph.incomingNeighbors(of: vertexId)
            let vertexIncomingNeighbors = incoming.filter { verticesIds.contains($0.vertex.id) }
            for neighbor in vertexIncomingNeighbors where diEdges[neighbor.edge.id] == nil {
                diEdges[neighbor.edge.id] = neighbor.edge
            }
            incomingNeighbors[vertexId] = vertexIncomingNeighbors.map { NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id) }
        }
        
        
        
//        let vertices = verticesIds.map {graph.diVertex($0)!}
//
//        var newEdges = [Int: E]()
//        var newVertices = [Int: V]()
//
//        for vertex in vertices {
//            var newInEdges = [Int]()
//            for inEdgeId in vertex.inEdges {
//                let inEdge = graph.diEdge(inEdgeId)!
//                if verticesIds.contains(inEdge.start) && verticesIds.contains(inEdge.end) {
//                    newEdges[inEdgeId] = inEdge
//                    newInEdges.append(inEdgeId)
//                }
//            }
//
//            var newOutEdges = [Int]()
//            for outEdgeId in vertex.outEdges {
//                let outEdge = graph.diEdge(outEdgeId)!
//                if verticesIds.contains(outEdge.start) && verticesIds.contains(outEdge.end) {
//                    newEdges[outEdgeId] = outEdge
//                    newOutEdges.append(outEdgeId)
//                }
//            }
//
//            let newOutNeighbors = vertex.outNeighbors.filter { verticesIds.contains($0) }
//            let newInNeighbors = vertex.inNeighbors.filter { verticesIds.contains($0) }
//
//            var vertex = vertex
//            vertex.inEdges = newInEdges
//            vertex.outEdges = newOutEdges
//            vertex.inNeighbors = newInNeighbors
//            vertex.outNeighbors = newOutNeighbors
//            newVertices[vertex.id] = vertex
//        }
//
//        self.diVertices = newVertices
//        self.diEdges = newEdges
//        self.newEdgeId = graph.newEdgeId
//        self.newVertexId = graph.newVertexId
    }
}



// Old functions below. TO delete.

extension DiGraph {
    
    @available(*, deprecated)
    mutating public func delete(vertexWithId id : V.Index) {
        // Delete edges that connect to the vertex.
        let vertex = diVertices[id]!
        remove(vertex: vertex)
        
//        for edgeId in vertex.inEdges {
//            delete(edgeWithId: edgeId)
//        }
//        for edgeId in vertex.outEdges {
//            delete(edgeWithId: edgeId)
//        }
//
//        diVertices.removeValue(forKey: id)
    }
    
    @available(*, deprecated)
    mutating public func delete(edgeWithId id: E.Index) {
        let edge = diEdges[id]!
        remove(edge: edge)
        
//        var vertex1 = diVertices[edge.start]!
//        vertex1.outEdges = vertex1.outEdges.filter {$0 != id}
//        vertex1.inEdges = vertex1.inEdges.filter {$0 != id}
//        vertex1.outNeighbors = vertex1.outEdges.map {diEdge($0)!.end}
//        vertex1.inNeighbors = vertex1.inEdges.map {diEdge($0)!.start}
//        diVertices[vertex1.id] = vertex1
//
//        var vertex2 = diVertices[edge.end]!
//        vertex2.outEdges = vertex2.outEdges.filter {$0 != id}
//        vertex2.inEdges = vertex2.inEdges.filter {$0 != id}
//        vertex2.outNeighbors = vertex2.outEdges.map {diEdge($0)!.end}
//        vertex2.inNeighbors = vertex2.inEdges.map {diEdge($0)!.start}
//        diVertices[vertex2.id] = vertex2
//
//        diEdges.removeValue(forKey: id)
    }
    
    
    
//    public func findEdge(from start: Int, to end: Int) -> [E] {
//        if let startVertex = diVertices[start], let endVertex = diVertices[end] {
//            return findEdge(from: startVertex, to: endVertex)
//        } else {
//            return []
//        }
//
//    }
    
    
    
    
    

    

    

}



extension DiGraph where DiGraph.V == IntVertex, DiGraph.E == IntDiEdge {
    public mutating func addNewVertex<Generator: IndexGenerator>(indexGenerator: inout Generator) -> V where Generator.Index == Int {
        let vertexId = indexGenerator.next()
        //self.newVertexId += 1
        let newVertex = V(id: vertexId)
        self.add(vertex: newVertex)
        return newVertex
    }
    public mutating func addEdge<Generator: IndexGenerator>(from startId: Int, to endId: Int, indexGenerator: inout Generator) -> E where Generator.Index == Int {
        let edgeId = indexGenerator.next()
//        self.newEdgeId += 1
        let newEdge = E(id: edgeId, start: startId, end: endId)
        self.diEdges[edgeId] = newEdge
        
        attachOutgoingEdge(to: startId, edgeId: edgeId, neighborId: endId)
        attachIncomingEdge(to: endId, edgeId: edgeId, neighborId: startId)
        
//        var start = self.diVertices[startId]!
//        var end = self.diVertices[endId]!
//        start.outEdges.append(edgeId)
//        start.outNeighbors.append(endId)
//        end.inEdges.append(edgeId)
//        end.inNeighbors.append(startId)
//        self.diVertices[startId] = start
//        self.diVertices[endId] = end
        return newEdge
    }
}


//public struct DiVertex : AbstractDiVertex {
//    public let id: Int
//    public var outEdges: [Int]
//    public var inEdges: [Int]
//    public var outNeighbors: [Int]
//    public var inNeighbors: [Int]
//
//    public init(id: Int) {
//        self.id = id
//        self.outEdges = []
//        self.inEdges = []
//        self.outNeighbors = []
//        self.inNeighbors = []
//    }
//}



