//
//  Components.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/9/18.
//

import Foundation


extension AbstractDiGraph {
    public func findAllVerticesInTheSameComponent(as vertexId: Int) -> Set<Int> {
        var component = [Int]()
        breadthFirstSearch(from: vertexId, callback: { (vertex) -> Bool in
            _ = component.append(vertex.id)
            return true
        })
        return Set(component)
    }
    
    public func areInTheSameComponent(vertices: [Int]) -> Bool {
        guard vertices.count > 1 else {
            return true
        }
        let start = vertices.first!
        var unvisited = Set(vertices[1...])
        breadthFirstSearch(from: start, callback: { (vertex) -> Bool in
            unvisited.remove(vertex.id)
            return !unvisited.isEmpty
            })
        return unvisited.isEmpty
    }
    
    public func areInTheSameCompanentAndContainAtLeastOne(vertices: [Int], atLeastOneVertices: [Int]) -> Bool {
        guard vertices.count > 1 else {
            return true
        }
        let start = vertices.first!
        var unvisited = Set(vertices[1...])
        let atLeastOneVerticesSet = Set(atLeastOneVertices)
        var visited = false
        breadthFirstSearch(from: start, callback: { (vertex) -> Bool in
            unvisited.remove(vertex.id)
            if atLeastOneVerticesSet.contains(vertex.id) {
                visited = true
            }
            return !(unvisited.isEmpty && visited)
        })
        return unvisited.isEmpty && visited
    }
}
