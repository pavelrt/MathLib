//
//  diGraph.swift
//  SwiftMath
//
//  Created by Pavel Rytir on 6/17/18.
//

import Foundation


public protocol AbstractDiVertex : AbstractVertex {
    var id : Int { get }
    var outEdges : [Int] { get set }
    var inEdges : [Int] { get set }
    
}

extension AbstractDiVertex {
    public var edges : [Int] {
        get {
            var edges = inEdges
            edges.append(contentsOf: outEdges)
            return edges
        }
    }
}

public protocol DiEdge : AbstractEdge {
    var id : Int { get set }
    var start : Int { get }
    var end : Int { get }
}

extension DiEdge {
    public var vertices : [Int] {
        get {
            return [start, end]
        }
    }
}
