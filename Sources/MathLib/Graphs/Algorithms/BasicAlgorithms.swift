//
//  BasicAlgorithms.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/23/18.
//

import Foundation

extension AbstractEdge {
  public var isLoop : Bool {
    return vertex1Id == vertex2Id
  }
}

extension AbstractDiEdge {
  public var isLoop : Bool {
    return start == end
  }
}

extension AbstractDiGraph {
  
  public func findEdge(from start: V.Index, to end: V.Index) -> [E] {
    let neighbors = outgoingNeighborsId(of: start)
    let edges = neighbors.filter {$0.vertexId == end } .map { diEdge($0.edgeId)! }
    return edges
  }
  
  // FIXME: Rename this
  public func connected(from start: V.Index, to end: V.Index) -> Bool {
    return !findEdge(from: start, to: end).isEmpty
  }
  
  @available(*, deprecated)
  public func findEdge(from start: V, to end: V) -> [E] {
    return findEdge(from: start.id, to: end.id)
  }
}

extension AbstractFiniteDiGraph {
  // FIXME: Rename to parallel edges.
  public var multiEdges : [[E.Index]] {
    
    var multiEdges = [[E.Index]]()
    for (vertexId, _) in diVertices {
      let groups = Dictionary(
        grouping: outgoingNeighbors(of: vertexId).map {($0.edge.id, $0.edge.end)}, by: { $0.1 })
      let duplicateGroups = groups.filter {$0.value.count > 1}
      multiEdges.append(contentsOf: duplicateGroups.map {$0.value.map {$0.0}})
    }
    return multiEdges
  }
}

extension AbstractMutableDiGraph {
  public mutating func removeAllEdgesBetween(v1Id: V.Index, v2Id: V.Index) {
    let edges = findEdge(from: v1Id, to: v2Id)
    for edge in edges {
      remove(edge: edge)
    }
    let reverseEdges = findEdge(from: v2Id, to: v1Id)
    for edge in reverseEdges {
      remove(edge: edge)
    }
  }
}
