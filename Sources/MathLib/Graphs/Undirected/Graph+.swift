//
//  Graph+.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/5/20.
//

import Foundation

extension Graph {
  
  // Will usualy result in multigraph.
  public init<DG: AbstractFiniteDiGraph>(diGraph: DG) where DG.V == V, DG.E == E {
    // , uniquingEdgesWith: (E,E) -> E
    self.vertices = Dictionary(uniqueKeysWithValues: Array(diGraph.diVertices))
    self.edges = Dictionary(uniqueKeysWithValues: Array(diGraph.diEdges))
    self.neighbors = [:]
    
    for (vertexId, _) in vertices {
      let outgoingNeighbors = diGraph.outgoingNeighbors(of: vertexId).map {NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)}
      let incomingNeighbors = diGraph.incomingNeighbors(of: vertexId).map {NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)}
      var vertexNeighbors = outgoingNeighbors
      vertexNeighbors.append(contentsOf: incomingNeighbors)
      self.neighbors[vertexId] = vertexNeighbors
    }
  }
  
  public init<G: AbstractFiniteGraph>(graph: G, inducedOn verticesIds: Set<V.Index>) where G.V == V, G.E == E {
    
    self.vertices = Dictionary(uniqueKeysWithValues: verticesIds.map { (vertexId: V.Index) -> (V.Index,V) in
      let vertex = graph.vertex(vertexId)!
      return (vertex.id, vertex)
    })
    self.neighbors = [:]
    
    self.edges = [E.Index: E]()
    
    for (vertexId, _) in vertices {
      
      let vertexNeighbors = graph.neighbors(of: vertexId).filter { verticesIds.contains($0.vertex.id) }
      for neighbor in vertexNeighbors where edges[neighbor.edge.id] == nil {
        edges[neighbor.edge.id] = neighbor.edge
      }
      neighbors[vertexId] = vertexNeighbors.map { NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id) }
    }
  }
  
  public init<G: AbstractFiniteGraph>(graph: G, onlyWithEdges edgesIds: Set<E.Index>) where G.V == V, G.E == E {
    
    
    self.edges = Dictionary(uniqueKeysWithValues: edgesIds.map { (key: $0, value: graph.edge($0)!) })
    
    var newVerticesIds = Set<V.Index>()
    
    for (_, edge) in edges {
      newVerticesIds.insert(edge.vertex1Id)
      newVerticesIds.insert(edge.vertex2Id)
    }
    
    self.vertices = Dictionary(uniqueKeysWithValues: newVerticesIds.map { ($0, graph.vertex($0)!) })
    self.neighbors = [:]
    
    for (vertexId, _) in vertices {
      let vertexNeighbors = graph.neighbors(of: vertexId).filter {edgesIds.contains($0.edge.id)}
      neighbors[vertexId] = vertexNeighbors.map { NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id) }
    }
  }
}

extension Graph : AbstractMutableGraph {
  public mutating func add(vertex: V) {
    guard vertices[vertex.id] == nil else {
      fatalError("Graph already contains a vertex with the same id.")
    }
    vertices[vertex.id] = vertex
  }
  
  public mutating func remove(vertex: V) {
    assert(vertices[vertex.id] != nil, "Removing non-existing vertex.")
    let vertexNeighbors = neighbors(of: vertex.id)
    for neighbor in vertexNeighbors {
      remove(edge: neighbor.edge)
    }
    vertices.removeValue(forKey: vertex.id)
    neighbors.removeValue(forKey: vertex.id)
  }
  
  public mutating func add(edge: E) {
    guard edges[edge.id] == nil else {
      fatalError("Graph already contains an edge with the same id.")
    }
    attachEdge(to: edge.vertex1Id, edgeId: edge.id, neighborId: edge.vertex2Id)
    if edge.vertex1Id != edge.vertex2Id {
      attachEdge(to: edge.vertex2Id, edgeId: edge.id, neighborId: edge.vertex1Id)
    }
    edges[edge.id] = edge
  }
  public mutating func remove(edge: E) {
    assert(edges[edge.id] != nil, "Removing non-existing edge.")
    removeEdge(from: edge.vertex1Id, edgeId: edge.id)
    if edge.vertex1Id != edge.vertex2Id {
      removeEdge(from: edge.vertex2Id, edgeId: edge.id)
    }
    edges.removeValue(forKey: edge.id)
  }
  
  private mutating func attachEdge(to vertexId: V.Index, edgeId: E.Index, neighborId: V.Index) {
    var vertexNeighbors = neighbors[vertexId] ?? []
    vertexNeighbors.append(NeighborTuple(vertexId: neighborId, edgeId: edgeId))
    neighbors[vertexId] = vertexNeighbors
  }
  private mutating func removeEdge(from vertexId: V.Index, edgeId: E.Index) {
    let vertexNeighbors = neighbors[vertexId]!.filter {$0.edgeId != edgeId}
    neighbors[vertexId] = vertexNeighbors
  }
  private mutating func filterNeighbors(of vertexId: V.Index, _ isIncluded: (NeighborTuple<V.Index, E.Index>) -> Bool) {
    let vertexNeighbors = (neighbors[vertexId] ?? []).filter { isIncluded($0) }
    neighbors[vertexId] = vertexNeighbors
  }
}

extension Graph {
  mutating public func removeParallelEdges(uniquingEdgesWith chooseEdge: ([E]) -> E) {
    var edgesIdToRemove = Set<E.Index>()
    var processedVertices = Set<V.Index>()
    for (vertexId, _) in vertices {
      let vertexNeighbors = neighbors[vertexId]!.filter { $0.vertexId != vertexId && !processedVertices.contains($0.vertexId) } // No loops.
      processedVertices.insert(vertexId)
      let allParallels = Dictionary(grouping: vertexNeighbors, by: { $0.vertexId })
      for (_, parallelNeighbors) in allParallels where parallelNeighbors.count > 1 {
        let parallelEdges = parallelNeighbors.map {edge($0.edgeId)!}
        let edgeToKeep = chooseEdge(parallelEdges)
        for edge in parallelEdges where edge.id != edgeToKeep.id {
          edgesIdToRemove.insert(edge.id)
        }
      }
    }
    for edgeId in edgesIdToRemove {
      remove(edge: edge(edgeId)!)
    }
  }
}

