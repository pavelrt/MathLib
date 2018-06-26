//
//  graph.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

public protocol AbstractVertex: Codable {
    var id : Int { get }
    var edges : [Int] { get }
}

public protocol AbstractEdge : Codable {
    var id : Int { get }
    var vertices : [Int] { get }
}


public protocol GraphProt {
    associatedtype V: AbstractVertex
    associatedtype E: AbstractEdge
    var vertices: [Int: V] { get }
    var edges: [Int: E] { get }
}

public protocol DiGraphProt : Codable {
    associatedtype V: AbstractDiVertex
    associatedtype E: DiEdge
    var vertices: [Int: V] { get }
    var edges: [Int: E] { get }
    mutating func add(edge: E)
    mutating func add(vertex: V)
}

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
