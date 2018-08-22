//
//  BFS.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/23/18.
//

extension AbstractDiGraph {
    public func breadthFirstSearch(from startId: Int, callback: (V) -> Bool, maxDepth : Int? = nil) {
        var fifo = Queue<Int>()
        var visited = Set<Int>()
        var hops = [Int:Int]()
        
        visited.insert(startId)
        fifo.enqueue(startId)
        hops[startId] = 0
        if !callback(vertex(startId)!) {
            return
        }
        
        while let vertexId = fifo.dequeue() {
            let firstVertex = vertex(vertexId)!
            if hops[vertexId]! < maxDepth ?? Int.max {
                for neigborhId in firstVertex.outNeighbors where !visited.contains(neigborhId) {
                    visited.insert(neigborhId)
                    fifo.enqueue(neigborhId)
                    hops[neigborhId] = hops[vertexId]! + 1
                    if !callback(vertex(neigborhId)!) {
                        return
                    }
                }
            }
        }
    }
    
    public func getVerticesId(withHopslessOrEqual hops: Int, from vertexId: Int) -> Set<Int> {
        var verticesId = Set<Int>()
        verticesId.insert(vertexId)
        let callback = { (vertex: V) -> Bool in
            verticesId.insert(vertex.id)
            return true
        }
        breadthFirstSearch(from: vertexId, callback: callback, maxDepth: hops)
        return verticesId
    }
}
