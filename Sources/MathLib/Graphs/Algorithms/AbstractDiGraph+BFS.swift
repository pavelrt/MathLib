//
//  BFS.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/23/18.
//

extension AbstractDiGraph {
  public func breadthFirstSearch(
    from startId: V.Index,
    callback: (V) -> Bool,
    maxDepth : Int? = nil)
  {
    var fifo = Queue<V.Index>()
    var visited = Set<V.Index>()
    var hops = [V.Index:Int]()
    
    visited.insert(startId)
    fifo.enqueue(startId)
    hops[startId] = 0
    if !callback(diVertex(startId)!) {
      return
    }
    
    while let firstVertexId = fifo.dequeue() {
      if hops[firstVertexId]! < maxDepth ?? Int.max {
        for neigborhId in outgoingNeighbors(of: firstVertexId) where
          !visited.contains(neigborhId.vertex.id)
        {
          visited.insert(neigborhId.vertex.id)
          fifo.enqueue(neigborhId.vertex.id)
          hops[neigborhId.vertex.id] = hops[firstVertexId]! + 1
          if !callback(diVertex(neigborhId.vertex.id)!) {
            return
          }
        }
      }
    }
  }
  
  public func getVerticesId(withHopslessOrEqual hops: Int, from vertexId: V.Index) -> Set<V.Index> {
    var verticesId = Set<V.Index>()
    verticesId.insert(vertexId)
    let callback = { (vertex: V) -> Bool in
      verticesId.insert(vertex.id)
      return true
    }
    breadthFirstSearch(from: vertexId, callback: callback, maxDepth: hops)
    return verticesId
  }
}

extension AbstractFiniteGraph {
  public func breadthFirstSearch(
    from startId: V.Index,
    callback: (V) -> Bool,
    maxDepth : Int? = nil)
  {
    var openSet = Queue<V.Index>()
    var closedSet = Set<V.Index>()
    var hops = [V.Index:Int]()
    
    openSet.enqueue(startId)
    hops[startId] = 0
    
    while let currentVertexId = openSet.dequeue() {
      let currentVertex = vertex(currentVertexId)!
      closedSet.insert(currentVertexId)
      if !callback(currentVertex) {
        return
      }
      if hops[currentVertexId]! < maxDepth ?? Int.max {
        for neigborh in neighbors(of: currentVertexId) where
          !closedSet.contains(neigborh.vertex.id)
        {
          openSet.enqueue(neigborh.vertex.id)
          hops[neigborh.vertex.id] = hops[currentVertexId]! + 1
        }
      }
    }
  }
  
}

