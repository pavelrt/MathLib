//
//  IndexGenerators.swift
//  MathLib
//
//  Created by Pavel Rytir on 9/24/18.
//

import Foundation

public protocol IndexGenerator {
    associatedtype Index : Hashable
    init()
    mutating func next() -> Index
    mutating func used<S: Sequence>(usedIndices: S) where S.Element == Index
}

extension IndexGenerator {
    public init<S: Sequence>(usedIndices: S)  where S.Element == Index {
        self.init()
        self.used(usedIndices: usedIndices)
    }
}

public struct GraphIndicesGenerator<VertexGenerator: IndexGenerator, EdgeGenerator: IndexGenerator> {
    public init() {
        self.edgeIdGenerator = EdgeGenerator()
        self.vertexIdGenerator = VertexGenerator()
    }
    private var edgeIdGenerator : EdgeGenerator
    private var vertexIdGenerator : VertexGenerator
}

extension GraphIndicesGenerator {
    public mutating func nextEdgeId() -> EdgeGenerator.Index {
        return edgeIdGenerator.next()
    }
    public mutating func nextVertexId() -> VertexGenerator.Index {
        return vertexIdGenerator.next()
    }
    public init<G: AbstractFiniteGraph>(graph : G) where G.V.Index == VertexGenerator.Index, G.E.Index == EdgeGenerator.Index {
        self.vertexIdGenerator = VertexGenerator(usedIndices: graph.vertices.map {$0.key})
        self.edgeIdGenerator = EdgeGenerator(usedIndices: graph.edges.map {$0.key})
    }
}

public typealias IntGraphIndicesGenerator = GraphIndicesGenerator<IntIndexGenerator,IntIndexGenerator>

public struct IntIndexGenerator : IndexGenerator {
    public typealias Index = Int
    
    public init() {
        self.availableValue = 1
    }
    
    public private(set) var availableValue : Int
    
    public mutating func next() -> Int {
        let value = availableValue
        self.availableValue += 1
        return value
    }
    
    public mutating func used<S>(usedIndices: S) where S : Sequence, IntIndexGenerator.Index == S.Element {
        let maxUsed = usedIndices.reduce(self.availableValue) { max($0,$1) }
        self.availableValue = maxUsed + 1
    }
    
}
