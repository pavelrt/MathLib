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
  associatedtype NeighborsIdCollection : Sequence where NeighborsIdCollection.Element == (edgeId: E.Index, vertexId: V.Index)
  
  func outgoingNeighbors(of vertexId: V.Index) -> NeighborsCollection
  func incomingNeighbors(of vertexId: V.Index) -> NeighborsCollection
  func outgoingNeighborsId(of vertexId: V.Index) -> NeighborsIdCollection
  func incomingNeighborsId(of vertexId: V.Index) -> NeighborsIdCollection
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
  mutating func update(edge: E)
  mutating func update(vertex: V)
}

