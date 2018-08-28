//
//  Kruskal.swift
//  
//
//
//

public func minimumSpanningTreeKruskal<G: AbstractGraph>(graph: G, lengths: (Int) -> Double) -> [Int] {
    //var cost = 0.0
    
    var edgesInSpanningTree = [Int]()
    let sortedEdges = Array(graph.edges.map {$0.0}).sorted(by: {lengths($0) < lengths($1)})
    
    var unionFind = UnionFindWeightedQuickUnionPathCompression<Int>()
    for (vertexId,_) in graph.vertices {
        unionFind.addSetWith(vertexId)
    }
    
    for edgeId in sortedEdges {
        let edge = graph.edge(edgeId)!
        let v1 = edge.vertices[0]
        let v2 = edge.vertices[1]
        if !unionFind.inSameSet(v1, and: v2) {
            //cost += lengths(edgeId)
            edgesInSpanningTree.append(edgeId)
            unionFind.unionSetsContaining(v1, and: v2)
        }
    }
    
    return edgesInSpanningTree
}
