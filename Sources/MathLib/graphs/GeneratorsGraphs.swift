//
//  GeneratorsGraphs.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/24/18.
//

import Foundation

public func createPath(length: Int) -> (IntGraph, IntVertex, IntVertex) {
    var indexer = IntGraphIndicesGenerator()
    return createPath(length: length, indexer: &indexer)
}
public func createPath<VG: IndexGenerator, EG: IndexGenerator>(length: Int, indexer : inout GraphIndicesGenerator<VG,EG> ) -> (IntGraph, IntVertex, IntVertex) where VG.Index == Int, EG.Index == Int {
    guard length >= 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    
//    var vertexIdGenerator = IntIndexGenerator()
//    var edgeIdGenerator = IntIndexGenerator()
    
    var graph = IntGraph()
    let firstVertex = IntVertex(id: indexer.nextVertexId())
    graph.add(vertex: firstVertex)
    var previousVertex = firstVertex
    
    for _ in 1...length {
        let nextVertex = IntVertex(id: indexer.nextVertexId())
        graph.add(vertex: nextVertex)
        let edgeBetweenPreviousAndNext = IntEdge(id: indexer.nextEdgeId(), vertices: TwoSet(previousVertex.id, nextVertex.id))
        graph.add(edge: edgeBetweenPreviousAndNext)
        previousVertex = nextVertex
    }
    return (graph, firstVertex, previousVertex)
}


public func createCircuit(length: Int) -> IntGraph {
    var indexer = IntGraphIndicesGenerator()
    return createCircuit(length: length, indexer: &indexer)
}
// Maybe overcomplicated.
public func createCircuit<VG: IndexGenerator, EG: IndexGenerator>(length: Int, indexer : inout GraphIndicesGenerator<VG,EG> ) -> IntGraph where VG.Index == Int, EG.Index == Int {
    guard length > 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var (path, start, end) = createPath(length: length - 1, indexer: &indexer)
    
    let lastEdge = IntEdge(id: indexer.nextEdgeId(), vertices: TwoSet(end.id, start.id))
    path.add(edge: lastEdge)
    return path
}

