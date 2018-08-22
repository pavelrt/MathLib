//
//  TransitiveClosure.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/21/18.
//

import Foundation

public func addTransitiveEdges<G: MutableAbstractDiGraph>(graph: G, maxDistance: Double, lengths: @escaping (Int) -> Double, edgeMaker: (Int, Int, Double) -> G.E) -> G {
    var newGraph = graph
    for vertex1 in graph.vertices.keys {
        let (distances, _) = shortestPathsDijkstra(in: graph, sourceId: vertex1, pathTo: [], lengths: lengths)
        for vertex2 in graph.vertices.keys {
            if let distance = distances[vertex2], distance <= maxDistance {
                let newEdge = edgeMaker(vertex1, vertex2, distance)
                newGraph.add(edge: newEdge)
            }
        }
    }
    return newGraph
}
