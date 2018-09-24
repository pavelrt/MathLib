//
//  dijkstra.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

fileprivate struct DistanceVertexId<Index> : Comparable {
    static func == (lhs: DistanceVertexId<Index>, rhs: DistanceVertexId<Index>) -> Bool {
        return lhs.dist == rhs.dist && lhs.orderId == rhs.orderId
    }
    
    static func < (lhs: DistanceVertexId, rhs: DistanceVertexId) -> Bool {
        return lhs.dist < rhs.dist || (lhs.dist == rhs.dist && lhs.orderId < rhs.orderId)
    }
    let dist : Double
    let vertexId : Index
    let orderId : Int
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
public func shortestPathsDijkstra<G: AbstractDiGraph>(in graph: G, sourceId: G.V.Index, pathTo: [G.V.Index], lengths: @escaping (G.E.Index) -> Double, distancesTo: Set<G.V.Index>? = nil) -> (distances: [G.V.Index: Double], paths: [G.V.Index:[(edge: G.E.Index, vertex: G.V.Index)]]) {
    
    var distancesToSet = distancesTo
    var closedSed = Set<G.V.Index>()
    var distances = [G.V.Index:Double]()
    var edgeToPredecesor = [G.V.Index:G.E.Index]()
    var openSet = PriorityQueue<DistanceVertexId<G.V.Index>>()
    var orderId = 0
    
    func computeDistances() {
        openSet.push(DistanceVertexId(dist: 0.0, vertexId: sourceId, orderId: orderId))
        orderId += 1
        distances[sourceId] = 0.0
        while let minDistVertex = openSet.pop() {
            let vertexId = minDistVertex.vertexId
            closedSed.insert(vertexId)
            
            distancesToSet?.remove(vertexId)
            if distancesToSet?.isEmpty ?? false {
                return
            }
            
            for neighborEdgeVertex in graph.outgoingNeighbors(of: vertexId) {
                let outEdge = neighborEdgeVertex.edge
                let neighbourId = outEdge.end
                let length = lengths(outEdge.id)
                assert(length >= 0.0)
                if !closedSed.contains(neighbourId) {
                    let newDistance = distances[vertexId]! + length
                    if newDistance < distances[neighbourId] ?? Double.infinity {
                        distances[neighbourId] = newDistance
                        openSet.push(DistanceVertexId(dist: newDistance, vertexId: neighbourId, orderId: orderId))
                        orderId += 1
                        edgeToPredecesor[neighbourId] = outEdge.id
                    }
                }
            }
        }
    }
    
    computeDistances()
    
    // path is a sequence of vertices from sourceId to v in pathTo
    var paths = [G.V.Index:[(edge: G.E.Index, vertex: G.V.Index)]]()
    for v in pathTo {
        assert(distancesTo?.contains(v) ?? true)
        var current = v
        var path = [(edge: G.E.Index, vertex: G.V.Index)]()
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


public func shortestPathAStar<G: AbstractDiGraph>(in graph: G, sourceId: G.V.Index, pathTo: G.V.Index, lengths: @escaping (G.E.Index) -> Double, heuristics: @escaping (G.V.Index) -> Double) -> (distance: Double?, path: [(edge: G.E.Index, vertex: G.V.Index)]?) {
    
    var closedSet = Set<G.V.Index>()
    var fScore = [G.V.Index:Double]()
    var gScore = [G.V.Index:Double]()
    var edgeToPredecesor = [G.V.Index:G.E.Index]()
    var openSet = PriorityQueue<DistanceVertexId<G.V.Index>>()
    var orderId = 0
    
    func computeDistances() {
        gScore[sourceId] = 0.0
        let initNodeFScore = heuristics(sourceId)
        fScore[sourceId] = initNodeFScore
        openSet.push(DistanceVertexId(dist: initNodeFScore, vertexId: sourceId, orderId: orderId))
        orderId += 1
        while let minFScoreVertex = openSet.pop() {
            let vertexId = minFScoreVertex.vertexId
            if vertexId == pathTo {
                return
            }
            closedSet.insert(vertexId)
            
            for neighborEdgeVertex in graph.outgoingNeighbors(of: vertexId) {
                let outEdge = neighborEdgeVertex.edge
                let neighborId = outEdge.end
                let length = lengths(outEdge.id)
                if !closedSet.contains(neighborId) {
                    let tentativeGScore = gScore[vertexId]! + length
                    assert(tentativeGScore >= 0.0)
                    if tentativeGScore < gScore[neighborId] ?? Double.infinity {
                        gScore[neighborId] = tentativeGScore
                        let newFScore = tentativeGScore + heuristics(neighborId)
                        openSet.push(DistanceVertexId(dist: newFScore, vertexId: neighborId, orderId: orderId))
                        orderId += 1
                        edgeToPredecesor[neighborId] = outEdge.id
                    }
                }
            }
        }
    }
    
    computeDistances()
    
    if let finalCost = gScore[pathTo] {
        
        // path is a sequence of vertices from sourceId to v in pathTo
        var current = pathTo
        var path = [(edge:G.E.Index,vertex:G.V.Index)]()
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


