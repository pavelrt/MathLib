//
//  basicGraphs.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation


public func createDiPath(length: Int) -> (DiGraph<DiVertex, AbstractDiEdge>, DiVertex, DiVertex) {
    guard length >= 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var graph = DiGraph<DiVertex, AbstractDiEdge>()
    let firstVertex = graph.addNewVertex()
    var previousVertex = firstVertex
    
    for _ in 1...length {
        let nextVertex = graph.addNewVertex()
        _ = graph.addEdge(from: previousVertex.id, to: nextVertex.id)
        previousVertex = nextVertex
    }
    return (graph, firstVertex, previousVertex)
}


public func createDiCircuit(length: Int) -> DiGraph<DiVertex, AbstractDiEdge> {
    guard length > 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var (path, start, end) = createDiPath(length: length - 1)
    _ = path.addEdge(from: end.id, to: start.id)
    return path
}

public func createDiGrid(dimensions: Int...) -> (DiGraph<DiVertex, AbstractDiEdge>, ([Int]) -> Int) {
    var grid = DiGraph<DiVertex, AbstractDiEdge>()
    
    let indexer : ([Int]) -> Int = { (coordinates: [Int]) -> Int  in
        var id = 0
        for coordinateIdx in coordinates.indices.reversed() {
            let coordinate = coordinates[coordinateIdx]
            id *= dimensions[coordinateIdx]
            id += coordinate
        }
        return id
    }
    
    func loop(_ function: @escaping ([Int])->()) {
        func generateCoordinates(dimIdx: Int, coordinates: [Int]) {
            if dimIdx >= dimensions.count {
                function(coordinates)
            } else {
                for i in 0..<dimensions[dimIdx] {
                    var newCoordinates = coordinates
                    newCoordinates.append(i)
                    generateCoordinates(dimIdx: dimIdx + 1, coordinates: newCoordinates)
                }
            }
        }
        generateCoordinates(dimIdx: 0, coordinates: [])
    }
    
    // Create vertices
    loop { coordinates in
        let vertex = DiVertex(id: indexer(coordinates))
        grid.add(vertex: vertex)
    }
    
    // Create edges
    loop { coordinates in
        let vertex = grid.vertices[indexer(coordinates)]!
        let vertexId = vertex.id
        for dimensionIdx in dimensions.indices {
            let coordinate = coordinates[dimensionIdx]
            if coordinate > 0 {
                var neighboorhCoordinates = coordinates
                neighboorhCoordinates[dimensionIdx] -= 1
                _ = grid.addEdge(from: vertexId, to: indexer(neighboorhCoordinates))
            }
            if coordinate < dimensions[dimensionIdx] - 1 {
                var neighboorhCoordinates = coordinates
                neighboorhCoordinates[dimensionIdx] += 1
                _ = grid.addEdge(from: vertexId, to: indexer(neighboorhCoordinates))
            }
        }
    }
    return (grid, indexer)
}
