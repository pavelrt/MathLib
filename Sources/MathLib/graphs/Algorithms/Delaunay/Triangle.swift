//
//  Triangle.swift
//  DelaunayTriangulationSwift
//
//  Created by Alex Littlejohn on 2016/01/08.
//  Copyright © 2016 zero. All rights reserved.
//

/// A simple struct representing 3 vertices
public struct Triangle<P:Abstract2DPoint> {
    
    public init(vertex1: DelaunayVertex<P>, vertex2: DelaunayVertex<P>, vertex3: DelaunayVertex<P>) {
        self.vertex1 = vertex1
        self.vertex2 = vertex2
        self.vertex3 = vertex3
    }
    
    public let vertex1: DelaunayVertex<P>
    public let vertex2: DelaunayVertex<P>
    public let vertex3: DelaunayVertex<P>
    
    var edges : [DelaunayEdge<P>] {
        get {
            return [DelaunayEdge(vertex1: vertex1.point!, vertex2: vertex2.point!), DelaunayEdge(vertex1: vertex2.point!, vertex2: vertex3.point!), DelaunayEdge(vertex1: vertex3.point!, vertex2: vertex1.point!)]
        }
    }
}
