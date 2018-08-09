//
//  diGraph.swift
//  SwiftMath
//
//  Created by Pavel Rytir on 6/17/18.
//

import Foundation

public protocol AbstractDiGraph : Hashable, Codable {
    associatedtype V: AbstractDiVertex
    associatedtype E: AbstractDiEdge
    var vertices: [Int: V] { get set }
    var edges: [Int: E] { get set }
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
    
    public func findEdge(from start: Int, to end: Int) -> [E] {
        return findEdge(from: vertices[start]!, to: vertices[end]!)
    }
    
    public func findEdge(from start: V, to end: V) -> [E] {
        return start.outEdges.map { ($0, edges[$0]!.end) } .filter { $0.1 == end.id } .map { edges[$0.0]! }
        
    }
    public var multiEdges : [[Int]] {
        
        var multiEdges = [[Int]]()
        for (_, vertex) in vertices {
            let groups = Dictionary(grouping: vertex.outEdges.map {($0, edges[$0]!.end)}, by: { $0.1 })
            let duplicateGroups = groups.filter {$0.value.count > 1}
            duplicateGroups.forEach { multiEdges.append($0.value.map {$0.0} )
            }
        }
        return multiEdges
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


