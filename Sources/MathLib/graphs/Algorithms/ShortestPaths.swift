//
//  ShortestPaths.swift
//  SimCore
//
//  Created by Pavel Rytir on 8/12/18.
//

import Foundation

public func findMinimalShortestPathsMatching<G: AbstractDiGraph>(in graph: G, startGroup: [Int], endGroup: [Int], lengths: @escaping (Int) -> Double) -> [(start: Int, end: Int, distance: Double)] {
    var distancesHeap = PriorityQueue<TwoVerticesDistance>()
    for startVertexId in startGroup {
        let (distances, _) = shortestPathsDijkstra(in: graph, sourceId: startVertexId, pathTo: [], lengths: lengths, distancesTo: Set(endGroup))
        for endVertexId in endGroup {
            distancesHeap.push(TwoVerticesDistance(startId: startVertexId, endId: endVertexId, distance: distances[endVertexId]!))
        }
    }
    var matching = [(start: Int, end: Int, distance: Double)]()
    var unfinishedStart = Multiset<Int>(startGroup)
    var unfinishedEnd = Multiset<Int>(endGroup)
    while let startEndDistance = distancesHeap.pop() {
        if unfinishedStart.contains(startEndDistance.startId) && unfinishedEnd.contains(startEndDistance.endId) {
            unfinishedStart.remove(startEndDistance.startId)
            unfinishedEnd.remove(startEndDistance.endId)
            matching.append((start: startEndDistance.startId, end: startEndDistance.endId, distance: startEndDistance.distance))
        }
    }
    return matching
}

fileprivate struct TwoVerticesDistance : Comparable {
    static func < (lhs: TwoVerticesDistance, rhs: TwoVerticesDistance) -> Bool {
        return lhs.distance < rhs.distance
    }
    
    let startId : Int
    let endId : Int
    let distance : Double
}


