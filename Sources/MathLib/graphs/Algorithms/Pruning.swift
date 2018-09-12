//
//  Pruning.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/11/18.
//

import Foundation

public func pruneEdges<G: AbstractMutableGraph>(of graph: G, probabilityToKeepEdge: Double) -> G {
    var edgesIdsToPrune = [Int]()
    
    for (edgeId, _) in graph.edges {
        let randomNumber = drand48()
        if randomNumber > probabilityToKeepEdge {
            edgesIdsToPrune.append(edgeId)
        }
    }
    
    var prunedGraph = graph
    
    for edgeId in edgesIdsToPrune {
        prunedGraph.remove(edge: prunedGraph.edge(edgeId)!)
    }
    return prunedGraph
}
