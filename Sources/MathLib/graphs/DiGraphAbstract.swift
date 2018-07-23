//
//  diGraph.swift
//  SwiftMath
//
//  Created by Pavel Rytir on 6/17/18.
//

import Foundation

public protocol AbstractDiGraph : Codable {
    associatedtype V: AbstractDiVertex
    associatedtype E: AbstractDiEdge
    var vertices: [Int: V] { get }
    var edges: [Int: E] { get }
    mutating func add(edge: E)
    mutating func add(vertex: V)
}

extension AbstractDiGraph {
    public func outgoingNeighborsIds(of vertexId: Int) -> [Int] {
        let vertex = vertices[vertexId]!
        return vertex.outEdges.map { edges[$0]!.end }
    }
    public func incomingNeighborsIds(of vertexId: Int) -> [Int] {
        let vertex = vertices[vertexId]!
        return vertex.inEdges.map { edges[$0]!.start }
    }
}

public protocol AbstractDiVertex : AbstractVertex {
    var id : Int { get }
    var outEdges : [Int] { get set }
    var inEdges : [Int] { get set }
    
}

extension AbstractDiVertex {
    public var edges : [Int] {
        get {
            var edges = inEdges
            edges.append(contentsOf: outEdges)
            return edges
        }
    }
    mutating public func remove(edgeWithId id: Int) {
        outEdges = outEdges.filter({ $0 != id })
        inEdges = inEdges.filter({ $0 != id })
    }
}

public protocol AbstractDiEdge : AbstractEdge {
    var id : Int { get set }
    var start : Int { get }
    var end : Int { get }
}

extension AbstractDiEdge {
    public var vertices : [Int] {
        get {
            return [start, end]
        }
    }
}


