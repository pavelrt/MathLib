//
//  DelaunayEdges.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/20/18.
//

import Foundation

public protocol Point2D : Hashable {
    var x : Double { get }
    var y : Double { get }
}

public struct DelaunayEdge<P: Point2D> : Hashable {
    public var hashValue: Int {
        get {
            return "\(vertex1)\(vertex2)".hashValue
        }
    }
    
    public static func == (lhs: DelaunayEdge<P>, rhs: DelaunayEdge<P>) -> Bool {
        return (lhs.vertex1 == rhs.vertex1 && lhs.vertex2 == rhs.vertex2) || (lhs.vertex1 == rhs.vertex2 && lhs.vertex2 == rhs.vertex1)
    }
    
    public let vertex1: P
    public let vertex2: P
}

public func delaunayEdges<P: Point2D>(points: [P]) -> [DelaunayEdge<P>] {
    let vertices = points.map {DelaunayVertex(point: $0)}
    let triangles = delaunayTriangulate(vertices: vertices)
    var edges = Set<DelaunayEdge<P>>()
    for triangle in triangles {
        edges = edges.union(Set(triangle.edges))
    }
    return Array(edges)
}
