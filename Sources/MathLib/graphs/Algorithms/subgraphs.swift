//
//  subgraphs.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/8/18.
//

import Foundation

extension AbstractDiGraph {
    mutating func induceSubgraph(on newVertices: [Int]) {
        let outEdges = Set(newVertices.flatMap { vertices[$0]!.outEdges })
        let inEdges = Set(newVertices.flatMap { vertices[$0]!.inEdges })
        let newEdges = outEdges.intersection(inEdges)
        let newEdgesTuples = newEdges.map { ($0, edges[$0]!) }
        edges = Dictionary(uniqueKeysWithValues: newEdgesTuples)
        
        let newVerticesTuples = newVertices.map { (vertexId) -> (Int, V) in
            var vertex = vertices[vertexId]!
            vertex.outEdges = vertex.outEdges.filter { newEdges.contains($0) }
            vertex.inEdges = vertex.inEdges.filter { newEdges.contains($0) }
            return (vertexId, vertex)
        }
        vertices = Dictionary(uniqueKeysWithValues: newVerticesTuples)
    }

}
