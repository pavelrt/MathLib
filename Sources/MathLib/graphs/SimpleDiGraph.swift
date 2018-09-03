//
//  abstractDiGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation

public struct DiVertex : AbstractDiVertex {
    
    public init(id: Int) {
        self.id = id
        self.outEdges = []
        self.inEdges = []
        self.outNeighbors = []
        self.inNeighbors = []
    }
    public let id: Int
    public var outEdges: [Int]
    public var inEdges: [Int]
    public var outNeighbors: [Int]
    public var inNeighbors: [Int]
}

public struct DiEdge : AbstractDiEdge {
    public init(id: Int, start from: Int, end to: Int) {
        self.start = from
        self.end = to
        self.id = id
    }
    public var id: Int
    public var start: Int
    public var end: Int
}

// FIXME: Optimize the methods in this structure.
public struct DiGraph<V: AbstractDiVertex, E: AbstractDiEdge> : MutableAbstractDiGraph {

    public var diVertices: [Int : V]
    public var diEdges: [Int : E]
    public var newEdgeId : Int
    public var newVertexId : Int
    
    public init() {
        self.diVertices = [:]
        self.diEdges = [:]
        self.newEdgeId = 1
        self.newVertexId = 1
    }
    public init<G: AbstractDiGraph>(graph: G) where G.V == V, G.E == E {
        let newVertices = Array(graph.diVertices) // FIXME:
        self.diVertices = Dictionary<Int,V>(uniqueKeysWithValues: newVertices)
        let newEdges = Array(graph.diEdges) // FIXME:
        self.diEdges = Dictionary(uniqueKeysWithValues: newEdges)
        self.newEdgeId = graph.newEdgeId
        self.newVertexId = graph.newVertexId
    }
    public init(diVertices: [Int : V], diEdges: [Int : E] ,newEdgeId : Int, newVertexId : Int) {
        self.diVertices = diVertices
        self.diEdges = diEdges
        self.newVertexId = newVertexId
        self.newEdgeId = newEdgeId
    }
    
    public init(isolatedVertices diVertices: [V]) {
        self.diVertices = [:]
        self.diVertices.reserveCapacity(diVertices.count)
        self.diEdges = [:]
        self.newEdgeId = 1
        self.newVertexId = 1
        for var vertex in diVertices {
            vertex.inEdges = []
            vertex.outEdges = []
            self.diVertices[vertex.id] = vertex
            self.newVertexId = max(self.newVertexId, vertex.id + 1)
        }
    }
    
    // FIXME: Write a test.
    public init<G: AbstractDiGraph>(graph: G, inducedOn verticesIds: Set<Int>) where G.V == V, G.E == E {
        
        let vertices = verticesIds.map {graph.diVertex($0)!}
        
        var newEdges = [Int: E]()
        var newVertices = [Int: V]()
        
        for vertex in vertices {
            var newInEdges = [Int]()
            for inEdgeId in vertex.inEdges {
                let inEdge = graph.diEdge(inEdgeId)!
                if verticesIds.contains(inEdge.start) && verticesIds.contains(inEdge.end) {
                    newEdges[inEdgeId] = inEdge
                    newInEdges.append(inEdgeId)
                }
            }
            
            var newOutEdges = [Int]()
            for outEdgeId in vertex.outEdges {
                let outEdge = graph.diEdge(outEdgeId)!
                if verticesIds.contains(outEdge.start) && verticesIds.contains(outEdge.end) {
                    newEdges[outEdgeId] = outEdge
                    newOutEdges.append(outEdgeId)
                }
            }
            
            let newOutNeighbors = vertex.outNeighbors.filter { verticesIds.contains($0) }
            let newInNeighbors = vertex.inNeighbors.filter { verticesIds.contains($0) }
            
            var vertex = vertex
            vertex.inEdges = newInEdges
            vertex.outEdges = newOutEdges
            vertex.inNeighbors = newInNeighbors
            vertex.outNeighbors = newOutNeighbors
            newVertices[vertex.id] = vertex
        }
        
        self.diVertices = newVertices
        self.diEdges = newEdges
        self.newEdgeId = graph.newEdgeId
        self.newVertexId = graph.newVertexId
        
//        let newDiEdges = Dictionary(uniqueKeysWithValues: graph.diEdges.filter { vertices.contains($0.value.start) && vertices.contains($0.value.end) })
//        let newDiVertices = Dictionary(uniqueKeysWithValues: graph.diVertices.filter { vertices.contains($0.key) } .map { vertexIdVertex -> (key: Int, value: V) in
//            var vertex = vertexIdVertex.value
//            vertex.outNeighbors = vertex.outNeighbors.filter {vertices.contains($0)}
//            vertex.inNeighbors = vertex.inNeighbors.filter {vertices.contains($0)}
//            vertex.outEdges = vertex.outEdges.filter { newDiEdges[$0] != nil }
//            vertex.inEdges = vertex.inEdges.filter { newDiEdges[$0] != nil }
//            return (key: vertexIdVertex.key, value: vertex)
//        })
//
//        self.diVertices = newDiVertices
//        self.diEdges = newDiEdges
        
        
    }
    
    public var verticesCount: Int {
        return diVertices.count
    }

    
    public func diVertex(_ id: Int) -> V? {
        return diVertices[id]
    }
    
    public func diEdge(_ id: Int) -> E? {
        return diEdges[id]
    }
    
    mutating public func delete(vertexWithId id : Int) {
        // Delete edges that connect to the vertex.
        let vertex = diVertices[id]!
        for edgeId in vertex.inEdges {
            delete(edgeWithId: edgeId)
        }
        for edgeId in vertex.outEdges {
            delete(edgeWithId: edgeId)
        }

        diVertices.removeValue(forKey: id)
    }
    
    mutating public func delete(edgeWithId id: Int) {
        let edge = diEdges[id]!
        var vertex1 = diVertices[edge.start]!
        vertex1.remove(edge: edge)
        diVertices[edge.start] = vertex1
        
        var vertex2 = diVertices[edge.end]!
        vertex2.remove(edge: edge)
        diVertices[edge.end] = vertex2
        
        diEdges.removeValue(forKey: id)
    }
    
    public func findEge(from start: Int, to end: Int) -> [E] {
        if let startVertex = diVertices[start], let endVertex = diVertices[end] {
            return findEdge(from: startVertex, to: endVertex)
        } else {
            return []
        }
        
    }
    
    public func connected(from start: Int, to end: Int) -> Bool {
        return !findEge(from: start, to: end).isEmpty
    }
    
    
    
    mutating public func add(edge: E) {
        var newEdge = edge
        newEdge.id = newEdgeId
        diEdges[newEdgeId] = newEdge
        
        var newStart = diVertices[newEdge.start]!
        var newEnd = diVertices[newEdge.end]!
        newStart.outEdges.append(newEdgeId)
        newStart.outNeighbors.append(newEdge.end)
        
        newEnd.inEdges.append(newEdgeId)
        newEnd.inNeighbors.append(newEdge.start)
        
        newEdgeId += 1
        diVertices[newEdge.start] = newStart
        diVertices[newEdge.end] = newEnd
    }
    
    public mutating func add(vertex: V) {
        self.diVertices[vertex.id] = vertex
        if newVertexId <= vertex.id {
            newVertexId = vertex.id + 1
        }
    }
}



extension DiGraph where DiGraph.V == DiVertex, DiGraph.E == DiEdge {
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
        self.diEdges[edgeId] = newEdge
        var start = self.diVertices[startId]!
        var end = self.diVertices[endId]!
        start.outEdges.append(edgeId)
        start.outNeighbors.append(endId)
        end.inEdges.append(edgeId)
        end.inNeighbors.append(startId)
        self.diVertices[startId] = start
        self.diVertices[endId] = end
        return newEdge
    }
}
