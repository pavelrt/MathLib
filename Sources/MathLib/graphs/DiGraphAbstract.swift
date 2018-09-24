//
//  diGraph.swift
//  SwiftMath
//
//  Created by Pavel Rytir on 6/17/18.
//

import Foundation

public protocol AbstractDiEdge {
    associatedtype Index: Hashable
    associatedtype VertexIndex : Hashable
    
    var id : Index { get }
    var start : VertexIndex { get }
    var end : VertexIndex { get }
}

public protocol AbstractDiGraph {
    associatedtype V: AbstractVertex
    associatedtype E: AbstractDiEdge where E.VertexIndex == V.Index
    associatedtype NeighborsCollection : Sequence where NeighborsCollection.Element == (edge: E, vertex: V)
    
    func outgoingNeighbors(of vertexId: V.Index) -> NeighborsCollection
    func incomingNeighbors(of vertexId: V.Index) -> NeighborsCollection
    func diVertex(_ id: V.Index) -> V?
    func diEdge(_ id: E.Index) -> E?
}

public protocol AbstractFiniteDiGraph : AbstractDiGraph {
    associatedtype VertexCollection : Collection where VertexCollection.Element == (key:V.Index, value: V)
    associatedtype EdgeCollection : Collection where EdgeCollection.Element == (key: E.Index, value: E)
    
    var diVertices: VertexCollection { get }
    var diEdges: EdgeCollection { get }
    var numberOfVertices : Int { get }
    var numberOfEdges : Int { get }
}

public protocol AbstractMutableDiGraph : AbstractFiniteDiGraph {
    mutating func add(edge: E)
    mutating func add(vertex: V)
    mutating func remove(edge: E)
    mutating func remove(vertex: V)
}






//public protocol AbstractDiVertex : AbstractVertex, Codable {
//    var id : Int { get }
//    var outEdges : [Int] { get set }
//    var inEdges : [Int] { get set }
//    var outNeighbors : [Int] { get set}
//    var inNeighbors : [Int] { get set }
//    //mutating func removeEdge(id: Int)
//}

//extension AbstractDiVertex {
////    public var edges : [Int] {
////        get {
////            var edges = inEdges
////            edges.append(contentsOf: outEdges)
////            return edges
////        }
////        set {
////            fatalError() // Not nice. FIXME:
////        }
////    }
//    public var neighbors : [Neighbor] {
//        get {
//            fatalError()
//
//            //return Array(Set(outNeighbors).union(Set(inNeighbors)))
//        }
//        set {
//            fatalError() // Not nice. FIXME:
//        }
//    }
////    @available(*, deprecated)
////    mutating public func remove<E: AbstractDiEdge>(edge: E) {
////        outEdges = outEdges.filter({ $0 != edge.id })
////        inEdges = inEdges.filter({ $0 != edge.id })
////        if self.id == edge.start {
////            outNeighbors = outNeighbors.filter { $0 != edge.end}
////        } else {
////            inNeighbors = inNeighbors.filter { $0 != edge.start}
////            assert(self.id == edge.end)
////        }
////    }
//}


//extension AbstractDiEdge {
//    public var vertex1 : Int {
//        return min(start, end)
//    }
//    public var vertex2 : Int {
//        return max(start, end)
//    }
//}


