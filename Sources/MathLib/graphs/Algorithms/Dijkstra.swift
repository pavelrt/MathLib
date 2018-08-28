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
///     - paths: The paths to the vertices specified by the parameter pathTo. Each path is sequence of tuples (edgeTo, vertex). So the path is sourceId,(edge,vertex),(edge,vertex)...(edge,destinationVertex).
public func shortestPathsDijkstra<G: AbstractDiGraph>(in graph: G, sourceId: Int, pathTo: [Int], lengths: @escaping (Int) -> Double, distancesTo: Set<Int>? = nil) -> (distances: [Int: Double], paths: [Int:[(edge: Int, vertex: Int)]]) {
    
    var distancesTo = distancesTo
    var finishedVertices = Set<Int>()
    var distances = [Int:Double]()
    var edgeToPredecesor = [Int:Int]()
    var heapDistanceVertexId = PriorityQueue<DistanceVertexId>()
    
    func computeDistances() {
        
        distances[sourceId] = 0.0
        finishedVertices.insert(sourceId)
        
        distancesTo?.remove(sourceId)
        if distancesTo?.isEmpty ?? false {
            return
        }
        
        for edgeId in graph.diVertex(sourceId)!.outEdges {
            let outEdge = graph.diEdge(edgeId)!
            let v = outEdge.end
            let length = lengths(edgeId)
            distances[v] = length
            heapDistanceVertexId.push(DistanceVertexId(dist: length, vertexId: v))
            edgeToPredecesor[v] = edgeId
        }
        
        while let minDistVertex = heapDistanceVertexId.pop() {
            let vertexId = minDistVertex.vertexId
            finishedVertices.insert(vertexId)
            
            distancesTo?.remove(vertexId)
            if distancesTo?.isEmpty ?? false {
                return
            }
            
            for edgeId in graph.diVertex(vertexId)!.outEdges {
                let outEdge = graph.diEdge(edgeId)!
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
    }
    
    computeDistances()
    
    // path is a sequence of vertices from sourceId to v in pathTo
    var paths = [Int:[(edge:Int,vertex:Int)]]()
    for v in pathTo {
        assert(distancesTo?.contains(v) ?? true)
        var current = v
        var path = [(edge:Int,vertex:Int)]()
        while let edge = edgeToPredecesor[current] {
            path.append((edge:edge,vertex:current))
            current = graph.diEdge(edge)!.start
        }
        //path.append(current)
        path.reverse()
        paths[v] = path
    }
    return (distances: distances, paths: paths)
}
