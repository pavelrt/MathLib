//
//  ShortestPaths.swift
//  SimCore
//
//  Created by Pavel Rytir on 8/12/18.
//

import Foundation

public func findMinimalShortestPathsMatching<G: AbstractFiniteDiGraph>(in graph: G, startGroup: [G.V.Index], endGroup: [G.V.Index], lengths: @escaping (G.E.Index) -> Double) -> [(start: G.V.Index, end: G.V.Index, distance: Double)] {
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


