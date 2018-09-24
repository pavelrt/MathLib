//
//  TransitiveClosure.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/21/18.
//

import Foundation

public func addTransitiveEdges<G: AbstractMutableDiGraph>(graph: G, maxDistance: Double, lengths: @escaping (G.E.Index) -> Double, edgeMaker: (G.V.Index, G.V.Index, Double) -> G.E) -> G {
    var newGraph = graph
    for (vertex1,_) in graph.diVertices {
        let (distances, _) = shortestPathsDijkstra(in: graph, sourceId: vertex1, pathTo: [], lengths: lengths)
        for (vertex2,_) in graph.diVertices {
            if let distance = distances[vertex2], distance <= maxDistance {
                let newEdge = edgeMaker(vertex1, vertex2, distance)
                if graph.findEdge(from: vertex1, to: vertex2).isEmpty {
                    newGraph.add(edge: newEdge)
                }
            }
        }
    }
    return newGraph
}
