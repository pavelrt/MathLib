//
//  Geometry.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/1/18.
//

import Foundation

public protocol Abstract2DPoint : Hashable {
    var x : Double { get }
    var y : Double { get }
}

public protocol Abstract3DPoint : Abstract2DPoint {
    var z : Double { get }
}

extension Abstract2DPoint {
    public func euclideanDistance<P: Abstract2DPoint>(to other: P) -> Double {
        return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2))
    }
}


extension Abstract3DPoint {
    public func euclideanDistance<P: Abstract3DPoint>(to other: P) -> Double {
        return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2) + pow(self.z - other.z, 2))
    }
    
    public func findIndexOfClosestPoint<P: Abstract3DPoint>(from points: [P]) -> Int {
        assert(!points.isEmpty)
        var minDist = Double.infinity
        var index = -1
        for pointIndex in points.indices {
            let distance = self.euclideanDistance(to: points[pointIndex])
            if distance < minDist {
                minDist = distance
                index = pointIndex
            }
        }
        return index
    }
}

public struct Point3D : Abstract3DPoint {
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    public let x : Double
    public let y : Double
    public let z : Double
}

extension Point3D {
    private func conv(_ a: Double, _ b: Double, _ t: Double) -> Double {
        return a * (1 - t) + t * b
    }
    public func convexCombination(with other: Point3D, t: Double) -> Point3D {
        return Point3D(x: conv(self.x, other.x, t), y: conv(self.y, other.y, t), z: conv(self.z, other.z, t))
    }
    
}

public struct Cuboid {
    public init(start: Point3D, end: Point3D) {
        self.start = start
        self.end = end
    }
    public let start : Point3D
    public let end : Point3D
}

public func splitSet<P: Abstract3DPoint>(_ set: [P], toClosests points: [P]) -> [P: [P]] {
    let intermediateDict = Dictionary(
      grouping: set.map { ($0, points[$0.findIndexOfClosestPoint(from: points)] )}, by: {$0.1})
    return intermediateDict.mapValues { $0.map { $0.0 } }
}

