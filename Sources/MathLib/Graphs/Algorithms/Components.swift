//
//  Components.swift
//  MathLib
//
//  Created by Pavel Rytir on 8/9/18.
//

import Foundation

extension AbstractFiniteDiGraph {
  public func findAllVerticesInTheSameComponent(as vertexId: V.Index) -> Set<V.Index> {
    var component = [V.Index]()
    breadthFirstSearch(from: vertexId, callback: { (vertex) -> Bool in
      _ = component.append(vertex.id)
      return true
    })
    return Set(component)
  }
  
  public func areInTheSameComponent(vertices: [V.Index]) -> Bool {
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
  
  public func areInTheSameCompanentAndContainAtLeastOne(
    vertices: [V.Index],
    atLeastOneVertices: [V.Index]) -> Bool
  {
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

extension AbstractFiniteGraph {
  public var components : [Int: [V.Index]] {
    var comps = [Int:[V.Index]]()
    var unfinished = Set(vertices.map {$0.key})
    var componentNumber = 1
    while !unfinished.isEmpty {
      let start = unfinished.removeFirst()
      var component = [V.Index]()
      breadthFirstSearch(from: start, callback: { vertex in
        component.append(vertex.id)
        unfinished.remove(vertex.id)
        return true
      })
      comps[componentNumber] = component
      componentNumber += 1
    }
    return comps
  }
}

