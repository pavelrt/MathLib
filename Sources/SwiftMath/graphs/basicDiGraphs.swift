//
//  basicGraphs.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation


public func createPath(length: Int) -> (DiGraph<AbstractDiVertex, AbstractDiEdge>, AbstractDiVertex, AbstractDiVertex) {
    guard length >= 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var graph = DiGraph<AbstractDiVertex, AbstractDiEdge>()
    let firstVertex = graph.addNewVertex()
    var previousVertex = firstVertex
    
    for _ in 1...length {
        let nextVertex = graph.addNewVertex()
        _ = graph.addEdge(from: previousVertex.id, to: nextVertex.id)
        previousVertex = nextVertex
    }
    return (graph, firstVertex, previousVertex)
}


public func createCircuit(length: Int) -> DiGraph<AbstractDiVertex, AbstractDiEdge> {
    guard length > 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var (path, start, end) = createPath(length: length - 1)
    _ = path.addEdge(from: end.id, to: start.id)
    return path
}
