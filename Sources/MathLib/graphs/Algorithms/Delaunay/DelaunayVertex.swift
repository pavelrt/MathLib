//
//  Vertex.swift
//  DelaunayTriangulationSwift
//
//  Created by Alex Littlejohn on 2016/01/08.
//  Copyright © 2016 zero. All rights reserved.
//

/// Container for a datatype that implements Point2D.
public struct DelaunayVertex<P: Abstract2DPoint> {
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
        self.point = nil
    }
    
    init(point: P) {
        self.x = point.x
        self.y = point.y
        self.point = point
    }
    
    let point : P?
    let x: Double
    let y: Double
}

extension DelaunayVertex: Equatable { }

public func ==<P: Abstract2DPoint>(lhs: DelaunayVertex<P>, rhs: DelaunayVertex<P>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension DelaunayVertex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x.hashValue)
        hasher.combine(y.hashValue)
    }
//    public var hashValue: Int {
//        return "\(x)\(y)".hashValue
//    }
}


