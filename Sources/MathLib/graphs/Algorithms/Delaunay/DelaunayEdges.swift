//
//  DelaunayEdges.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/20/18.
//

import Foundation

public struct DelaunayEdge<P: Abstract2DPoint> : Hashable {
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

public func delaunayEdges<P: Abstract2DPoint>(points: [P]) -> [DelaunayEdge<P>] {
    let vertices = points.map {DelaunayVertex(point: $0)}
    let triangles = delaunayTriangulate(vertices: vertices)
    var edges = Set<DelaunayEdge<P>>()
    for triangle in triangles {
        edges = edges.union(Set(triangle.edges))
    }
    //FIXME: There is some strange swift 4.1 bug when we use "Array(edges)". Try again for swift 4.2. or send bug report. Fails in generating game with 17 UAVs.
    var a = [DelaunayEdge<P>]()
    a.reserveCapacity(edges.count)
    for e in edges {
        a.append(e)
    }
    return a
}
