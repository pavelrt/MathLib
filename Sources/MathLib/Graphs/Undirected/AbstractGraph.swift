//
//  graph.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

public protocol AbstractVertex {
  associatedtype Index: Hashable & Comparable
  var id: Index { get }
}

public protocol AbstractEdge {
  associatedtype Index: Hashable & Comparable
  associatedtype VertexIndex: Hashable & Comparable
  var id: Index { get }
  var vertices: TwoSet<VertexIndex> { get }
}

extension AbstractEdge {
  public var vertex1Id: VertexIndex {
    return vertices.e1
  }
  public var vertex2Id: VertexIndex {
    return vertices.e2
  }
}

public protocol AbstractGraph {
  associatedtype V: AbstractVertex
  associatedtype E: AbstractEdge where E.VertexIndex == V.Index
  associatedtype NeighborsCollection: Sequence where
    NeighborsCollection.Element == (edge: E, vertex: V)
  func neighbors(of vertexId: V.Index) -> NeighborsCollection
  func vertex(_ id: V.Index) -> V?
  func edge(_ id: E.Index) -> E?
}

public protocol AbstractFiniteGraph: AbstractGraph {
  associatedtype VertexCollection: Collection where
    VertexCollection.Element == (key:V.Index, value: V)
  associatedtype EdgeCollection: Collection where EdgeCollection.Element == (key: E.Index, value: E)
  
  var vertices: VertexCollection { get }
  var edges: EdgeCollection { get }
  var numberOfVertices: Int { get }
  var numberOfEdges: Int { get }
}


public protocol AbstractMutableGraph : AbstractFiniteGraph {
  mutating func add(edge: E)
  mutating func add(vertex: V)
  mutating func remove(edge: E)
  mutating func remove(vertex: V)
}
