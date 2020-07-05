//
//  simpleGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation


public struct Graph<V: AbstractVertex, E: AbstractEdge>: AbstractFiniteGraph where
  V.Index == E.VertexIndex
{
  public typealias VertexCollection = [V.Index:V]
  public typealias EdgeCollection = [E.Index:E]
  public typealias NeighborsCollection = [(edge: E, vertex: V)]
  
  public internal(set) var vertices: VertexCollection
  public internal(set) var edges: EdgeCollection
  internal var neighbors : [V.Index: [NeighborTuple<V.Index,E.Index>]]
  
  /// Creates an empty graph.
  public init() {
    self.vertices = [:]
    self.edges = [:]
    self.neighbors = [:]
  }
  
  public func neighbors(of vertexId: V.Index) -> NeighborsCollection {
    return (neighbors[vertexId] ?? []).map {(edge: edge($0.edgeId)!, vertex: vertex($0.vertexId)!)}
  }
  
  public var numberOfVertices : Int {
    return vertices.count
  }
  
  public var numberOfEdges : Int {
    return edges.count
  }
  
  public func vertex(_ id: V.Index) -> V? {
    return vertices[id]
  }
  
  public func edge(_ id: E.Index) -> E? {
    return edges[id]
  }
}

struct NeighborTuple<VertexIndex: Hashable, EdgeIndex: Hashable> : Hashable {
  public let vertexId : VertexIndex
  public let edgeId : EdgeIndex
}


extension Graph: Equatable where V: Equatable, E: Equatable {}

extension Graph: Hashable where V: Hashable, E:Hashable {}

extension NeighborTuple: Codable where VertexIndex : Codable, EdgeIndex : Codable {}

extension Graph: Codable where V: Codable, E: Codable, V.Index : Codable, E.Index: Codable {}
