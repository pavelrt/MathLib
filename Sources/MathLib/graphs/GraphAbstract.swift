//
//  graph.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

public protocol AbstractVertex: Hashable {
    var id : Int { get }
    var neighbors : [Neighbor] { get } // Change to Set?
}

public struct Neighbor : Hashable, Codable {
    public let vertexId : Int
    public let edgeId : Int
}

public protocol AbstractMutableVertex : AbstractVertex {
    mutating func attachEdge(edgeId: Int, neighborId: Int)
    mutating func removeEdge(id: Int)
    mutating func filterNeighbors(_ isIncluded: (Neighbor) -> Bool)
}

public protocol AbstractEdge : Hashable {
    var id : Int { get }
    var vertex1 : Int { get }
    var vertex2 : Int { get }
}


public protocol AbstractGraph : Hashable {
    associatedtype V: AbstractVertex
    associatedtype E: AbstractEdge
    associatedtype VertexCollection : Collection where VertexCollection.Element == (key:Int, value: V)
    associatedtype EdgeCollection : Collection where EdgeCollection.Element == (key: Int, value: E)
    func vertex(_ id: Int) -> V?
    func edge(_ id: Int) -> E?
    var vertices: VertexCollection { get }
    var edges: EdgeCollection { get }
    var availableVertexId : Int { get }
    var availableEdgeId : Int { get }
    var numberOfVertices : Int { get }
    var numberOfEdges : Int { get }
}

public protocol AbstractMutableGraph : AbstractGraph {
    mutating func add(edge: E)
    mutating func remove(edge: E)
}




