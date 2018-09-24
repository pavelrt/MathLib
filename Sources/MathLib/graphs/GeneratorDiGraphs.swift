//
//  basicGraphs.swift
//  SwiftMath
//
//  Created by Pavel R on 13/06/2018.
//

import Foundation


public func createDiPath(length: Int) -> (IntDiGraph, IntVertex, IntVertex) {
    guard length >= 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var vertexIdGenerator = IntIndexGenerator()
    var edgeIdGenerator = IntIndexGenerator()
    
    var graph = DiGraph<IntVertex, IntDiEdge>()
    let firstVertex = graph.addNewVertex(indexGenerator: &vertexIdGenerator)
    var previousVertex = firstVertex
    
    for _ in 1...length {
        let nextVertex = graph.addNewVertex(indexGenerator: &vertexIdGenerator)
        _ = graph.addEdge(from: previousVertex.id, to: nextVertex.id, indexGenerator: &edgeIdGenerator)
        previousVertex = nextVertex
    }
    return (graph, firstVertex, previousVertex)
}


public func createDiCircuit(length: Int) -> IntDiGraph {
    guard length > 0 else {
        fatalError("The length of the path has to be positive!")
    }
    
    var (path, start, end) = createDiPath(length: length - 1)
    
    var edgeIdGenerator = IntIndexGenerator()
    edgeIdGenerator.used(usedIndices: path.diEdges.map {$0.key})
    
    _ = path.addEdge(from: end.id, to: start.id, indexGenerator: &edgeIdGenerator)
    return path
}

//fileprivate func createDiGridVertex<V: AbstractDiVertex>(coordinates: [Int]) -> V {
//    
//}
//
public func createDiGrid<V: AbstractVertex, E: AbstractDiEdge>(dimensions: [Int], vertexMaker: @escaping ([Int], Int) -> V, edgeMaker: @escaping ([Int], Int, [Int], Int) -> E, initialGraph: DiGraph<V,E> ) -> (DiGraph<V,E>, ([Int]) -> Int) {
    var graph = initialGraph
    // First, create the indexer.
    let indexer : ([Int]) -> Int = { (coordinates: [Int]) -> Int  in
        var id = 0
        for coordinateIdx in coordinates.indices.reversed() {
            let coordinate = coordinates[coordinateIdx]
            id *= dimensions[coordinateIdx]
            id += coordinate
        }
        return id
    }
    
    // Define a looper over all possible coordinates.
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
    
    // Second, add vertices using vertex creator.
    loop { coordinates in
        let vertex = vertexMaker(coordinates, indexer(coordinates))
        graph.add(vertex: vertex)
    }
    
    // Third, add all grid edges.
    loop { coordinates in
        //let vertex = graph.vertices[indexer(coordinates)]!
        //let vertexId = vertex.id
        for dimensionIdx in dimensions.indices {
            let coordinate = coordinates[dimensionIdx]
            if coordinate > 0 {
                var neighboorhCoordinates = coordinates
                neighboorhCoordinates[dimensionIdx] -= 1
                let edge = edgeMaker(coordinates, indexer(coordinates), neighboorhCoordinates, indexer(neighboorhCoordinates))
                graph.add(edge: edge)
            }
            if coordinate < dimensions[dimensionIdx] - 1 {
                var neighboorhCoordinates = coordinates
                neighboorhCoordinates[dimensionIdx] += 1
                let edge = edgeMaker(coordinates, indexer(coordinates), neighboorhCoordinates, indexer(neighboorhCoordinates))
                graph.add(edge: edge)
            }
        }
    }
    
    return (graph, indexer)
}

// FIXME: Test this
public func createDiGrid2(dimensions: Int...) -> (IntDiGraph, ([Int]) -> Int) {
    let initGrid = IntDiGraph()
    var edgeIdGenerator = IntIndexGenerator()
    let vertexMaker = { (_: [Int], id: Int) -> IntVertex in
        return IntVertex(id: id)
    }
    let edgeMaker = { (_: [Int], vertex1Id: Int, _: [Int], vertex2Id: Int) -> IntDiEdge in
        return IntDiEdge(id: edgeIdGenerator.next(), start: vertex1Id, end: vertex2Id)
    }
    let (grid, indexer) = createDiGrid(dimensions: dimensions, vertexMaker: vertexMaker, edgeMaker: edgeMaker, initialGraph: initGrid)
    return (grid, indexer)
}

public func createDiGrid(dimensions: Int...) -> (IntDiGraph, ([Int]) -> Int) {
    var grid = IntDiGraph()
    var edgeIdGenerator = IntIndexGenerator()
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
        let vertex = IntVertex(id: indexer(coordinates))
        grid.add(vertex: vertex)
    }
    
    // Create edges
    loop { coordinates in
        let vertex = grid.diVertices[indexer(coordinates)]!
        let vertexId = vertex.id
        for dimensionIdx in dimensions.indices {
            let coordinate = coordinates[dimensionIdx]
            if coordinate > 0 {
                var neighboorhCoordinates = coordinates
                neighboorhCoordinates[dimensionIdx] -= 1
                _ = grid.addEdge(from: vertexId, to: indexer(neighboorhCoordinates), indexGenerator: &edgeIdGenerator)
            }
            if coordinate < dimensions[dimensionIdx] - 1 {
                var neighboorhCoordinates = coordinates
                neighboorhCoordinates[dimensionIdx] += 1
                _ = grid.addEdge(from: vertexId, to: indexer(neighboorhCoordinates), indexGenerator: &edgeIdGenerator)
            }
        }
    }
    return (grid, indexer)
}
