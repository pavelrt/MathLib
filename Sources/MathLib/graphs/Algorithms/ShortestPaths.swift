//
//  ShortestPaths.swift
//  SimCore
//
//  Created by Pavel Rytir on 8/12/18.
//

import Foundation

public func findGreedyLongPath<G:AbstractDiGraph>(in graph: G, from: G.V.Index, visiting vertices: [G.V.Index], lengths: @escaping (G.E.Index) -> Double) -> (Double, [(G.E.Index, G.V.Index)])? {
    var unvisited = Set(vertices)
    var currentFrom = from
    var path = [(G.E.Index, G.V.Index)]()
    var totalDistance = 0.0
    while !unvisited.isEmpty {
        let (distances, paths) = shortestPathsDijkstra(in: graph, sourceId: currentFrom, pathTo: Array(unvisited), lengths: lengths, distancesTo: unvisited)
        if let farestVertexIdPathDistance = distances.filter({ unvisited.contains($0.key) }).max(by: {$0.value < $1.value}) {
            path.append(contentsOf: paths[farestVertexIdPathDistance.key]!)
            totalDistance += farestVertexIdPathDistance.value
            unvisited.remove(farestVertexIdPathDistance.key)
            currentFrom = farestVertexIdPathDistance.key
        } else {
            return nil
        }
    }
    
    return (totalDistance, path)
}

public func findGreedyPath<G:AbstractDiGraph>(in graph: G, from: G.V.Index, visiting vertices: [G.V.Index], lengths: @escaping (G.E.Index) -> Double) -> (Double, [(G.E.Index, G.V.Index)])? {
    var unvisited = Set(vertices)
    var currentFrom = from
    var path = [(G.E.Index, G.V.Index)]()
    var totalDistance = 0.0
    while !unvisited.isEmpty {
        let (distances, paths) = shortestPathsDijkstra(in: graph, sourceId: currentFrom, pathTo: Array(unvisited), lengths: lengths, distancesTo: unvisited)
        if let nearestVertexIdPathDistance = distances.filter({ unvisited.contains($0.key) }).min(by: {$0.value < $1.value}) {
            path.append(contentsOf: paths[nearestVertexIdPathDistance.key]!)
            totalDistance += nearestVertexIdPathDistance.value
            unvisited.remove(nearestVertexIdPathDistance.key)
            currentFrom = nearestVertexIdPathDistance.key
        } else {
            return nil
        }
    }
    
    return (totalDistance, path)
}

public func findAllShortestPaths<G: AbstractDiGraph>(in graph: G, startGroup: [G.V.Index], endGroup: [G.V.Index], lengths: @escaping (G.E.Index) -> Double) -> [(start: G.V.Index, end: G.V.Index, distance: Double)] {
    var shortestPaths = [(start: G.V.Index, end: G.V.Index, distance: Double)]()
    for startVertexId in startGroup {
        let (distances, _) = shortestPathsDijkstra(in: graph, sourceId: startVertexId, pathTo: [], lengths: lengths, distancesTo: Set(endGroup))
        for endVertexId in endGroup {
            shortestPaths.append((start: startVertexId, end: endVertexId, distance: distances[endVertexId]!))
        }
    }
    return shortestPaths
}

public func findMinimalShortestPathsMatching<G: AbstractDiGraph>(in graph: G, startGroup: [G.V.Index], endGroup: [G.V.Index], lengths: @escaping (G.E.Index) -> Double) -> [(start: G.V.Index, end: G.V.Index, distance: Double)] {
    var distancesHeap = PriorityQueue<TwoVerticesDistance<G.V.Index>>()
    var orderId = 0
    for startVertexId in startGroup {
        let (distances, _) = shortestPathsDijkstra(in: graph, sourceId: startVertexId, pathTo: [], lengths: lengths, distancesTo: Set(endGroup))
        for endVertexId in endGroup {
            distancesHeap.push(TwoVerticesDistance(startId: startVertexId, endId: endVertexId, distance: distances[endVertexId]!, orderId: orderId))
            orderId += 1
        }
    }
    var matching = [(start: G.V.Index, end: G.V.Index, distance: Double)]()
    var unfinishedStart = Multiset<G.V.Index>(startGroup)
    var unfinishedEnd = Multiset<G.V.Index>(endGroup)
    while let startEndDistance = distancesHeap.pop() {
        if unfinishedStart.contains(startEndDistance.startId) && unfinishedEnd.contains(startEndDistance.endId) {
            unfinishedStart.remove(startEndDistance.startId)
            unfinishedEnd.remove(startEndDistance.endId)
            matching.append((start: startEndDistance.startId, end: startEndDistance.endId, distance: startEndDistance.distance))
        }
    }
    return matching
}

fileprivate struct TwoVerticesDistance<Index> : Comparable {
    static func == (lhs: TwoVerticesDistance<Index>, rhs: TwoVerticesDistance<Index>) -> Bool {
        return lhs.distance == rhs.distance && lhs.orderId == rhs.orderId
    }
    
    static func < (lhs: TwoVerticesDistance, rhs: TwoVerticesDistance) -> Bool {
        return lhs.distance < rhs.distance || (lhs.distance == rhs.distance && lhs.orderId < rhs.orderId)
    }
    
    let startId : Index
    let endId : Index
    let distance : Double
    let orderId : Int
}


