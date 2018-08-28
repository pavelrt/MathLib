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
    associatedtype VertexCollection : Collection where VertexCollection.Element == (key:Int, value: V)
    associatedtype EdgeCollection : Collection where EdgeCollection.Element == (key: Int, value: E)
    func diVertex(_ id: Int) -> V?
    func diEdge(_ id: Int) -> E?
    
    var verticesCount : Int { get }
    
    var diVertices: VertexCollection { get }
    var diEdges: EdgeCollection { get }
    
    var newVertexId : Int { get }
    var newEdgeId : Int { get }
}



public protocol MutableAbstractDiGraph : AbstractDiGraph {
    mutating func add(edge: E)
    mutating func add(vertex: V)
    var diVertices: VertexCollection { get set }
    var diEdges: EdgeCollection { get set }
}

extension AbstractDiGraph {
    @available(*, deprecated)
    public func outgoingNeighborsIds(of vertexId: Int) -> [Int] {
        let vertex = diVertex(vertexId)!
        return vertex.outEdges.map { diEdge($0)!.end }
    }
    @available(*, deprecated)
    public func incomingNeighborsIds(of vertexId: Int) -> [Int] {
        let vertex = diVertex(vertexId)!
        return vertex.inEdges.map { diEdge($0)!.start }
    }
    
    public func findEdge(from start: Int, to end: Int) -> [E] {
        return findEdge(from: self.diVertex(start)!, to: self.diVertex(end)!)
    }
    
    public func findEdge(from start: V, to end: V) -> [E] {
        return start.outEdges.map { ($0, self.diEdge($0)!.end) } .filter { $0.1 == end.id } .map { self.diEdge($0.0)! }
        
    }
    public var multiEdges : [[Int]] {
        
        var multiEdges = [[Int]]()
        for (_, vertex) in diVertices {
            let groups = Dictionary(grouping: vertex.outEdges.map {($0, self.diEdge($0)!.end)}, by: { $0.1 })
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
    var outNeighbors : [Int] { get set}
    var inNeighbors : [Int] { get set }
}

extension AbstractDiVertex {
    public var edges : [Int] {
        get {
            var edges = inEdges
            edges.append(contentsOf: outEdges)
            return edges
        }
    }
    public var neighbors : [Int] {
        return outNeighbors + inNeighbors
    }
    mutating public func remove<E: AbstractDiEdge>(edge: E) {
        outEdges = outEdges.filter({ $0 != edge.id })
        inEdges = inEdges.filter({ $0 != edge.id })
        if self.id == edge.start {
            outNeighbors = outNeighbors.filter { $0 != edge.end}
        } else {
            inNeighbors = inNeighbors.filter { $0 != edge.start}
            assert(self.id == edge.end)
        }
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


