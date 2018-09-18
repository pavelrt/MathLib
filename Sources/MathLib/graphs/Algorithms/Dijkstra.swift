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
    
    var distancesToSet = distancesTo
    var closedSed = Set<Int>()
    var distances = [Int:Double]()
    var edgeToPredecesor = [Int:Int]()
    var openSet = PriorityQueue<DistanceVertexId>()
    
    func computeDistances() {
        openSet.push(DistanceVertexId(dist: 0.0, vertexId: sourceId))
        distances[sourceId] = 0.0
        while let minDistVertex = openSet.pop() {
            let vertexId = minDistVertex.vertexId
            closedSed.insert(vertexId)
            
            distancesToSet?.remove(vertexId)
            if distancesToSet?.isEmpty ?? false {
                return
            }
            
            for edgeId in graph.diVertex(vertexId)!.outEdges {
                let outEdge = graph.diEdge(edgeId)!
                let neighbour = outEdge.end
                let length = lengths(edgeId)
                assert(length >= 0.0)
                if !closedSed.contains(neighbour) {
                    let newDistance = distances[vertexId]! + length
                    if newDistance < distances[neighbour] ?? Double.infinity {
                        distances[neighbour] = newDistance
                        openSet.push(DistanceVertexId(dist: newDistance, vertexId: neighbour))
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


public func shortestPathAStar<G: AbstractDiGraph>(in graph: G, sourceId: Int, pathTo: Int, lengths: @escaping (Int) -> Double, heuristics: @escaping (Int) -> Double) -> (distance: Double?, path: [(edge: Int, vertex: Int)]?) {
    
    var closedSet = Set<Int>()
    var fScore = [Int:Double]()
    var gScore = [Int:Double]()
    var edgeToPredecesor = [Int:Int]()
    var openSet = PriorityQueue<DistanceVertexId>()
    
    func computeDistances() {
        gScore[sourceId] = 0.0
        let initNodeFScore = heuristics(sourceId)
        fScore[sourceId] = initNodeFScore
        openSet.push(DistanceVertexId(dist: initNodeFScore, vertexId: sourceId))
        while let minFScoreVertex = openSet.pop() {
            let vertexId = minFScoreVertex.vertexId
            if vertexId == pathTo {
                return
            }
            closedSet.insert(vertexId)
            
            for edgeId in graph.diVertex(vertexId)!.outEdges {
                let outEdge = graph.diEdge(edgeId)!
                let neighbour = outEdge.end
                let length = lengths(edgeId)
                if !closedSet.contains(neighbour) {
                    let tentativeGScore = gScore[vertexId]! + length
                    assert(tentativeGScore >= 0.0)
                    if tentativeGScore < gScore[neighbour] ?? Double.infinity {
                        gScore[neighbour] = tentativeGScore
                        let newFScore = tentativeGScore + heuristics(neighbour)
                        openSet.push(DistanceVertexId(dist: newFScore, vertexId: neighbour))
                        edgeToPredecesor[neighbour] = edgeId
                    }
                }
            }
        }
    }
    
    computeDistances()
    
    if let finalCost = gScore[pathTo] {
        
        // path is a sequence of vertices from sourceId to v in pathTo
        var current = pathTo
        var path = [(edge:Int,vertex:Int)]()
        while let edge = edgeToPredecesor[current] {
            path.append((edge:edge,vertex:current))
            current = graph.diEdge(edge)!.start
        }
        //path.append(current)
        path.reverse()
        
        return (distance: finalCost, path: path)
    } else {
        return (nil,nil)
    }
}


