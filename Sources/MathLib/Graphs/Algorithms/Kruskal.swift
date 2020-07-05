//
//  Kruskal.swift
//  
//
//
//

public func edgesOfMinimalSpanningTreeKruskal<G: AbstractFiniteGraph>(
  graph: G,
  lengths: (G.E.Index) -> Double) -> [G.E.Index]
{
  //var cost = 0.0
  
  var edgesInSpanningTree = [G.E.Index]()
  let sortedEdges = Array(graph.edges.map {$0.0}).sorted(by: {lengths($0) < lengths($1)})
  
  var unionFind = UnionFindWeightedQuickUnionPathCompression<G.V.Index>()
  for (vertexId,_) in graph.vertices {
    unionFind.addSetWith(vertexId)
  }
  
  for edgeId in sortedEdges {
    let edge = graph.edge(edgeId)!
    let v1 = edge.vertex1Id
    let v2 = edge.vertex2Id
    if !unionFind.inSameSet(v1, and: v2) {
      //cost += lengths(edgeId)
      edgesInSpanningTree.append(edgeId)
      unionFind.unionSetsContaining(v1, and: v2)
    }
  }
  
  return edgesInSpanningTree
}
