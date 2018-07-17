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

// FIXME: Optimize the methods in this structure.
public struct DiGraph<V: AbstractDiVertex, E: DiEdge> : DiGraphProt {
    public init() {
        self.vertices = [:]
        self.edges = [:]
        self.newEdgeId = 1
        self.newVertexId = 1
    }
    public init(vertices: [Int : V], edges: [Int : E] ,newEdgeId : Int, newVertexId : Int) {
        self.vertices = vertices
        self.edges = edges
        self.newVertexId = newVertexId
        self.newEdgeId = newEdgeId
    }
    public init(isolatedVertices vertices: [V]) {
        self.vertices = [:]
        self.vertices.reserveCapacity(vertices.count)
        self.edges = [:]
        self.newEdgeId = 1
        self.newVertexId = 1
        for vertex in vertices {
            self.vertices[vertex.id] = vertex
            self.newVertexId = max(self.newVertexId, vertex.id + 1)
        }
    }
    
    public var vertices: [Int : V]
    public var edges: [Int : E]
    public var newEdgeId : Int
    public var newVertexId : Int
    
    mutating public func delete(vertexWithId id : Int) {
        // Delete edges that connect to the vertex.
        let vertex = vertices[id]!
        for edgeId in vertex.inEdges {
            delete(edgeWithId: edgeId)
        }
        for edgeId in vertex.outEdges {
            delete(edgeWithId: edgeId)
        }

        vertices.removeValue(forKey: id)
    }
    
    mutating public func delete(edgeWithId id: Int) {
        let edge = edges[id]!
        var vertex1 = vertices[edge.start]!
        vertex1.remove(edgeWithId: id)
        vertices[edge.start] = vertex1
        
        var vertex2 = vertices[edge.end]!
        vertex2.remove(edgeWithId: id)
        vertices[edge.end] = vertex2
        
        edges.removeValue(forKey: id)
    }
    
    public func findEge(from start: Int, to end: Int) -> E? {
        if let startVertex = vertices[start], let endVertex = vertices[end] {
            return findEdge(from: startVertex, to: endVertex)
        } else {
            return nil
        }
        
    }
    
    public func connected(from start: Int, to end: Int) -> Bool {
        return findEge(from: start, to: end) != nil
    }
    
    public func findEdge(from start: V, to end: V) -> E? {
        for edgeId in start.outEdges { // Maybe improve the speed by using some hashmap
            let edge = edges[edgeId]!
            if edge.end == end.id {
                return edge
            }
        }
        return nil
    }
    
    mutating public func add(edge: E) {
        var newEdge = edge
        newEdge.id = newEdgeId
        edges[newEdgeId] = newEdge
        
        var newStart = vertices[newEdge.start]!
        var newEnd = vertices[newEdge.end]!
        newStart.outEdges.append(newEdgeId)
        
        newEnd.inEdges.append(newEdgeId)
        
        newEdgeId += 1
        vertices[newEdge.start] = newStart
        vertices[newEdge.end] = newEnd
    }
    public mutating func add(vertex: V) {
        self.vertices[vertex.id] = vertex
        if newVertexId <= vertex.id {
            newVertexId = vertex.id + 1
        }
    }
}



extension DiGraph where DiGraph.V == DiVertex, DiGraph.E == AbstractDiEdge {
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