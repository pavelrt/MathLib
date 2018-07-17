//
//  graph.swift
//  SwiftMath
//
//  Created by Pavel R on 12/06/2018.
//

import Foundation

public protocol AbstractVertex: Codable {
    var id : Int { get }
    var edges : [Int] { get }
}

public protocol AbstractEdge : Codable {
    var id : Int { get }
    var vertices : [Int] { get }
}


public protocol GraphProt {
    associatedtype V: AbstractVertex
    associatedtype E: AbstractEdge
    var vertices: [Int: V] { get }
    var edges: [Int: E] { get }
}


