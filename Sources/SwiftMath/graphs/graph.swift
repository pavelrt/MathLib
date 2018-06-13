//
//  graph.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

public protocol Vertex: Codable {
    var id : Int { get }
    var edges : [Int] { get }
}

public protocol Edge : Codable {
    var id : Int { get }
    var vertices : [Int] { get }
}

public protocol DiVertex : Vertex {
    var id : Int { get }
    var outEdges : [Int] { get set }
    var inEdges : [Int] { get set }
    
}

extension DiVertex {
    public var edges : [Int] {
        get {
            var edges = inEdges
            edges.append(contentsOf: outEdges)
            return edges
        }
    }
}

public protocol DiEdge : Edge {
    var id : Int { get set }
    var start : Int { get }
    var end : Int { get }
}

extension DiEdge {
    public var vertices : [Int] {
        get {
            return [start, end]
        }
    }
}

public protocol GraphProt {
    associatedtype V: Vertex
    associatedtype E: Edge
    var vertices: [Int: V] { get }
    var edges: [Int: E] { get }
}

public protocol DiGraphProt : Codable {
    associatedtype V: DiVertex
    associatedtype E: DiEdge
    var vertices: [Int: V] { get }
    var edges: [Int: E] { get }
    mutating func add(edge: E)
    mutating func add(vertex: V)
}

public struct DiGraph<V: DiVertex, E: DiEdge> : DiGraphProt {
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
    }
}
