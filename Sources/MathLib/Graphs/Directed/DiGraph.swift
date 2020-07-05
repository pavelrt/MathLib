//
//  abstractDiGraph.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation

public struct DiGraph<V: AbstractVertex, E: AbstractDiEdge>: AbstractFiniteDiGraph where
  V.Index == E.VertexIndex
{
  public typealias VertexCollection = [V.Index:V]
  public typealias EdgeCollection = [E.Index:E]
  public typealias NeighborsCollection = [(edge: E, vertex: V)]
  public typealias NeighborsIdCollection = [(edgeId: E.Index, vertexId: V.Index)]
  
  
  public private(set) var diVertices: VertexCollection
  public private(set) var diEdges: EdgeCollection
  private var outgoingNeighbors : [V.Index: [NeighborTuple<V.Index,E.Index>]]
  private var incomingNeighbors : [V.Index: [NeighborTuple<V.Index,E.Index>]]
  
  public init() {
    self.diVertices = [:]
    self.diEdges = [:]
    self.outgoingNeighbors = [:]
    self.incomingNeighbors = [:]
  }
  
  public func outgoingNeighbors(of vertexId: E.VertexIndex) -> NeighborsCollection {
    let vertexOutgoingNeighborsIds = outgoingNeighbors[vertexId] ?? []
    let vertexOutgoingNeighbors = vertexOutgoingNeighborsIds.map {
      (edge: diEdge($0.edgeId)!, vertex: diVertex($0.vertexId)!)
    }
    return vertexOutgoingNeighbors
  }
  
  public func outgoingNeighborsId(of vertexId: E.VertexIndex) -> NeighborsIdCollection {
    let vertexOutgoingNeighborsIds = outgoingNeighbors[vertexId] ?? []
    let vertexOutgoingNeighborsIds2 = vertexOutgoingNeighborsIds.map {
      (edgeId: $0.edgeId, vertexId: $0.vertexId)
    }
    return vertexOutgoingNeighborsIds2
  }
  
  public func incomingNeighbors(of vertexId: E.VertexIndex) -> NeighborsCollection {
    let vertexIncomingNeighborsIds = incomingNeighbors[vertexId] ?? []
    let vertexIncomingNeighbors = vertexIncomingNeighborsIds.map {
      (edge: diEdge($0.edgeId)!, vertex: diVertex($0.vertexId)!)
    }
    return vertexIncomingNeighbors
  }
  
  public func incomingNeighborsId(of vertexId: E.VertexIndex) -> NeighborsIdCollection {
    let vertexIncomingNeighborsIds = incomingNeighbors[vertexId] ?? []
    let vertexIncomingNeighborsIds2 = vertexIncomingNeighborsIds.map {
      (edgeId: $0.edgeId, vertexId: $0.vertexId)
    }
    return vertexIncomingNeighborsIds2
  }
  
  public var numberOfVertices: Int {
    return diVertices.count
  }
  
  public var numberOfEdges: Int {
    return diEdges.count
  }
  
  @available(*, deprecated)
  public var verticesCount: Int {
    return numberOfVertices
  }
  
  
  public func diVertex(_ id: V.Index) -> V? {
    return diVertices[id]
  }
  
  public func diEdge(_ id: E.Index) -> E? {
    return diEdges[id]
  }
}

extension DiGraph : AbstractMutableDiGraph {
  mutating public func add(edge: E) {
    guard diEdges[edge.id] == nil else {
      fatalError("Graph already contains an edge with the same id.")
    }
    attachOutgoingEdge(to: edge.start, edgeId: edge.id, neighborId: edge.end)
    attachIncomingEdge(to: edge.end, edgeId: edge.id, neighborId: edge.start)
    diEdges[edge.id] = edge
  }
  
  public mutating func add(vertex: V) {
    guard diVertices[vertex.id] == nil else {
      fatalError("Graph already contains a vertex with the same id.")
    }
    diVertices[vertex.id] = vertex
  }
  
  public mutating func remove(edge: E) {
    assert(diEdges[edge.id] != nil, "Removing non-existing edge.")
    removeOutgoingEdge(from: edge.start, edgeId: edge.id)
    removeIncomingEdge(from: edge.end, edgeId: edge.id)
    diEdges.removeValue(forKey: edge.id)
  }
  
  public mutating func remove(vertex: V) {
    assert(diVertices[vertex.id] != nil, "Removing non-existing vertex.")
    let vertexOutgoingNeighbors = outgoingNeighbors(of: vertex.id)
    for neighbor in vertexOutgoingNeighbors {
      remove(edge: neighbor.edge)
    }
    let vertexIncomingNeighbors = incomingNeighbors(of: vertex.id)
    for neighbor in vertexIncomingNeighbors {
      remove(edge: neighbor.edge)
    }
    diVertices.removeValue(forKey: vertex.id)
    outgoingNeighbors.removeValue(forKey: vertex.id)
    incomingNeighbors.removeValue(forKey: vertex.id)
  }
  
  public mutating func update(edge: E) {
    guard let oldEdge = diEdge(edge.id) else {
      fatalError("Updating non-existing edge.")
    }
    if oldEdge.start == edge.start && oldEdge.end == edge.end {
      diEdges[edge.id] = edge
    } else {
      remove(edge: oldEdge)
      add(edge: edge)
    }
  }
  
  public mutating func update(vertex: V) {
    guard diVertex(vertex.id) != nil else {
      fatalError("Updating non-existing vertex.")
    }
    diVertices[vertex.id] = vertex
  }
}

extension DiGraph {
  private mutating func attachOutgoingEdge(
    to vertexId: V.Index,
    edgeId: E.Index,
    neighborId: V.Index)
  {
    var vertexOutgoingNeighbors = outgoingNeighbors[vertexId] ?? []
    vertexOutgoingNeighbors.append(NeighborTuple(vertexId: neighborId, edgeId: edgeId))
    outgoingNeighbors[vertexId] = vertexOutgoingNeighbors
  }
  private mutating func attachIncomingEdge(
    to vertexId: V.Index,
    edgeId: E.Index,
    neighborId: V.Index)
  {
    var vertexIncomingNeighbors = incomingNeighbors[vertexId] ?? []
    vertexIncomingNeighbors.append(NeighborTuple(vertexId: neighborId, edgeId: edgeId))
    incomingNeighbors[vertexId] = vertexIncomingNeighbors
  }
  private mutating func removeOutgoingEdge(from vertexId: V.Index, edgeId: E.Index) {
    let vertexOutgoingNeighbors = outgoingNeighbors[vertexId]!.filter {$0.edgeId != edgeId}
    outgoingNeighbors[vertexId] = vertexOutgoingNeighbors
  }
  private mutating func removeIncomingEdge(from vertexId: V.Index, edgeId: E.Index) {
    let vertexIncomingNeighbors = incomingNeighbors[vertexId]!.filter {$0.edgeId != edgeId}
    incomingNeighbors[vertexId] = vertexIncomingNeighbors
  }
}

extension DiGraph: Equatable where V: Equatable, E: Equatable {}

extension DiGraph : Hashable where V: Hashable, E:Hashable {}

extension DiGraph : Codable where V: Codable, E: Codable, V.Index : Codable, E.Index: Codable {}


extension DiGraph {
  
  public init<G: AbstractFiniteDiGraph>(graph: G) where G.V == V, G.E == E {
    //let origGraphVertices = Array(graph.diVertices)
    
    self.diVertices = Dictionary(uniqueKeysWithValues: Array(graph.diVertices)) // FIXME: Remove Array
    self.diEdges = Dictionary(uniqueKeysWithValues: Array(graph.diEdges)) // FIXME: Remove Array
    self.outgoingNeighbors = [:]
    self.incomingNeighbors = [:]
    
    for (vertexId, _) in diVertices {
      self.outgoingNeighbors[vertexId] = graph.outgoingNeighbors(of: vertexId).map {
        NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)
      }
      self.incomingNeighbors[vertexId] = graph.incomingNeighbors(of: vertexId).map {
        NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)
      }
    }
    
  }
  
  public init(isolatedVertices diVertices: [V]) {
    self.diVertices = Dictionary(uniqueKeysWithValues: diVertices.map {($0.id, $0)})
    self.diEdges = [:]
    self.outgoingNeighbors = [:]
    self.incomingNeighbors = [:]
  }
  
  public init<G: AbstractFiniteDiGraph>(
    graph: G,
    onlyWithEdges edgesIds: Set<E.Index>,
    keepAllVertices: Bool) where G.V == V, G.E == E
  {
    
    self.diEdges = Dictionary(uniqueKeysWithValues: edgesIds.map {
      (key: $0, value: graph.diEdge($0)!)
    })
    
    let newVerticesIds : Set<V.Index>
    if keepAllVertices {
      newVerticesIds = Set(graph.diVertices.map {$0.key})
    } else {
      var verticesIds = Set<V.Index>()
      for (_, edge) in diEdges {
        verticesIds.insert(edge.start)
        verticesIds.insert(edge.end)
      }
      newVerticesIds = verticesIds
    }
    
    
    self.diVertices = Dictionary(uniqueKeysWithValues: newVerticesIds.map {
      ($0, graph.diVertex($0)!)
    })
    self.outgoingNeighbors = [:]
    self.incomingNeighbors = [:]
    
    for (vertexId, _) in diVertices {
      let vertexOutgoingNeighbors = graph.outgoingNeighbors(of: vertexId).filter {
        edgesIds.contains($0.edge.id)
      }
      outgoingNeighbors[vertexId] = vertexOutgoingNeighbors.map {
        NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)
      }
      let vertexIncomingNeighbors = graph.incomingNeighbors(of: vertexId).filter {
        edgesIds.contains($0.edge.id)
      }
      incomingNeighbors[vertexId] = vertexIncomingNeighbors.map {
        NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)
      }
    }
  }
  
  
  // FIXME: Write a test.
  public init<G: AbstractFiniteDiGraph>(
    graph: G,
    inducedOn verticesIds: Set<V.Index>) where G.V == V, G.E == E
  {
    self.diVertices = Dictionary(uniqueKeysWithValues: verticesIds.map { (vertexId: V.Index) -> (V.Index,V) in
      let vertex = graph.diVertex(vertexId)!
      return (vertex.id, vertex)
    })
    self.outgoingNeighbors = [:]
    self.outgoingNeighbors.reserveCapacity(verticesIds.count)
    self.incomingNeighbors = [:]
    self.incomingNeighbors.reserveCapacity(verticesIds.count)
    
    self.diEdges = [E.Index: E]()
    
    for (vertexId, _) in diVertices {
      let outgoing = graph.outgoingNeighbors(of: vertexId)
      let vertexOutgoingNeighbors = outgoing.filter { verticesIds.contains($0.vertex.id) }
      for neighbor in vertexOutgoingNeighbors where diEdges[neighbor.edge.id] == nil {
        diEdges[neighbor.edge.id] = neighbor.edge
      }
      outgoingNeighbors[vertexId] = vertexOutgoingNeighbors.map {
        NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)
      }
      
      let incoming = graph.incomingNeighbors(of: vertexId)
      let vertexIncomingNeighbors = incoming.filter { verticesIds.contains($0.vertex.id) }
      for neighbor in vertexIncomingNeighbors where diEdges[neighbor.edge.id] == nil {
        diEdges[neighbor.edge.id] = neighbor.edge
      }
      incomingNeighbors[vertexId] = vertexIncomingNeighbors.map {
        NeighborTuple(vertexId: $0.vertex.id, edgeId: $0.edge.id)
      }
    }
  }
}



//TODO: Old functions below. TO delete.

extension DiGraph {
  
  @available(*, deprecated)
  mutating public func delete(vertexWithId id : V.Index) {
    // Delete edges that connect to the vertex.
    let vertex = diVertices[id]!
    remove(vertex: vertex)
  }
  
  @available(*, deprecated)
  mutating public func delete(edgeWithId id: E.Index) {
    let edge = diEdges[id]!
    remove(edge: edge)
  }
}

extension DiGraph where DiGraph.V == IntVertex, DiGraph.E == IntDiEdge {
  public mutating func addNewVertex<Generator: IndexGenerator>(indexGenerator: inout Generator) -> V where Generator.Index == Int {
    let vertexId = indexGenerator.next()
    let newVertex = V(id: vertexId)
    self.add(vertex: newVertex)
    return newVertex
  }
  public mutating func addEdge<Generator: IndexGenerator>(from startId: Int, to endId: Int, indexGenerator: inout Generator) -> E where Generator.Index == Int {
    let edgeId = indexGenerator.next()
    //        self.newEdgeId += 1
    let newEdge = E(id: edgeId, start: startId, end: endId)
    self.diEdges[edgeId] = newEdge
    
    attachOutgoingEdge(to: startId, edgeId: edgeId, neighborId: endId)
    attachIncomingEdge(to: endId, edgeId: edgeId, neighborId: startId)
    return newEdge
  }
}


