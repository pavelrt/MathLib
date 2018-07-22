//
//  dijkstra.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

fileprivate struct DistanceVertexId : Comparable {
    static func < (lhs: DistanceVertexId, rhs: DistanceVertexId) -> Bool {
        return lhs.dist < rhs.dist || (lhs.dist == rhs.dist && lhs.vertexId < rhs.vertexId)
    }
    let dist : Double
    let vertexId : Int
}
/// Dijsktra algorithm for finding a shortest path.
///
/// - Parameters:
///     - graph: The graph where we are searching the shortest path.
///     - sourceId: Id of the source vertex
///     - pathTo: Id of the vertices to which we want to find the shortest paths.
///     - lengths: A function that takes id of an edge as a parameter and returns the length of the edge.
/// - Returns:
///     - distances: The lengths of the shortest paths to all reachable vertices.
///     - paths: The paths to the vertices specified by the parameter pathTo. Each path is sequence ov vertices (ids).
public func shortestPathsDijkstra<G: DiGraphProt>(in graph: G, sourceId: Int, pathTo: [Int], lengths: (Int) -> Double) -> (distances: [Int: Double], paths: [Int:[Int]]) {
    
    var finishedVertices = Set<Int>()
    var distances = [Int:Double]()
    var edgeToPredecesor = [Int:Int]()
    var heapDistanceVertexId = PriorityQueue<DistanceVertexId>()
    
    distances[sourceId] = 0.0
    finishedVertices.insert(sourceId)
    
    for edgeId in graph.vertices[sourceId]!.outEdges {
        let outEdge = graph.edges[edgeId]!
        let v = outEdge.end
        let length = lengths(edgeId)
        distances[v] = length
        heapDistanceVertexId.push(DistanceVertexId(dist: length, vertexId: v))
        edgeToPredecesor[v] = edgeId
    }
    
    while let minDistVertex = heapDistanceVertexId.pop() {
        let vertexId = minDistVertex.vertexId
        finishedVertices.insert(vertexId)
        for edgeId in graph.vertices[vertexId]!.outEdges {
            let outEdge = graph.edges[edgeId]!
            let neighbour = outEdge.end
            let length = lengths(edgeId)
            if !finishedVertices.contains(neighbour) {
                if distances[vertexId]! + length < distances[neighbour] ?? Double.infinity {
                    distances[neighbour] = distances[vertexId]! + length
                    heapDistanceVertexId.push(DistanceVertexId(dist: distances[neighbour]!, vertexId: neighbour))
                    edgeToPredecesor[neighbour] = edgeId
                }
            }
        }
    }
    // path is a sequence of vertices from sourceId to v in pathTo
    var paths = [Int:[Int]]()
    for v in pathTo {
        var current = v
        var path = [Int]()
        while let edge = edgeToPredecesor[current] {
            path.append(current)
            current = graph.edges[edge]!.start
        }
        path.append(current)
        path.reverse()
        paths[v] = path
    }
    return (distances: distances, paths: paths)
}
