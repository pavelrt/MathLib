//
//  IntDiGraph.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/5/20.
//

import Foundation

public struct IntDiEdge : AbstractDiEdge {
  public typealias Index = Int
  public typealias VertexIndex = Int
  public init(id: Index, start from: VertexIndex, end to: VertexIndex) {
    self.start = from
    self.end = to
    self.id = id
  }
  public var id: Index
  public var start: VertexIndex
  public var end: VertexIndex
}

public typealias IntDiGraph = DiGraph<IntVertex,IntDiEdge>
