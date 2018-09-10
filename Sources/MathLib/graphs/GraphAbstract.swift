//
//  graph.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

public protocol AbstractVertex: Hashable, Codable {
    var id : Int { get }
    var edges : [Int] { get set }
    var neighbors : [Int] { get set }
}

public protocol AbstractEdge : Hashable, Codable {
    var id : Int { get }
    var vertices : [Int] { get }
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


