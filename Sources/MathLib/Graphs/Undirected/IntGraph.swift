//
//  IntGraph.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/5/20.
//

import Foundation

public typealias IntGraph = Graph<IntVertex,IntEdge>

public struct IntVertex : AbstractVertex {
  public typealias Index = Int
  public let id: Index
}

public struct IntEdge : AbstractEdge {
  public typealias Index = Int
  public typealias VertexIndex = Int
  
  public let id: Index
  public var vertices: TwoSet<Int>
}
