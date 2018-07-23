//
//  BFS.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/23/18.
//

extension AbstractDiGraph {
    public func breadthFirstSearch(from startId: Int, callback: (V) -> (), maxDepth : Int? = nil) {
        var fifo = Queue<Int>()
        var visited = Set<Int>()
        var hops = [Int:Int]()
        
        visited.insert(startId)
        fifo.enqueue(startId)
        hops[startId] = 0
        callback(vertices[startId]!)
        
        while let vertexId = fifo.dequeue() {
            if hops[vertexId]! < maxDepth ?? Int.max {
                for neigborhId in outgoingNeighborsIds(of: vertexId) where !visited.contains(neigborhId) {
                    visited.insert(neigborhId)
                    fifo.enqueue(neigborhId)
                    hops[neigborhId] = hops[vertexId]! + 1
                    callback(vertices[neigborhId]!)
                }
            }
        }
    }
    public func getVerticesId(withHopslessOrEqual hops: Int, from vertexId: Int) -> Set<Int> {
        var verticesId = Set<Int>()
        verticesId.insert(vertexId)
        let callback = { (vertex: V) -> () in
            verticesId.insert(vertex.id)
        }
        breadthFirstSearch(from: vertexId, callback: callback, maxDepth: hops)
        return verticesId
    }
}
