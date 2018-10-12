//
//  Pruning.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/11/18.
//

import Foundation

public func pruneEdges<G: AbstractMutableGraph>(of graph: G, probabilityToKeepEdge: Double) -> G {
    var edgesIdsToPrune = [G.E.Index]()
    
    for (edgeId, _) in graph.edges {
        let randomNumber = Double.random(in: 0..<1)
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
