//
//  AStarGraph.swift
//  MathLib
//
//  Created by Pavel Rytir on 5/6/19.
//

import Foundation

public protocol AStarNode : Hashable {
  associatedtype E
  var outgoingEdges : [E] { get }
  func neighbor(connectedBy edge: E) -> (node: Self, cost: Double)?
  var heuristics : Double { get }
  var final : Bool { get }
}


public func aStarSearch<N: AStarNode>(
  from initNode: N,
  pruneFunction: ((N) -> Bool)?,
  continueFunction: (() -> Bool)? = nil,
  checkContinueCount: Int? = nil,
  maxSetSize: Int = 2_000_000,
  verbose: Bool = false) -> (solution: N, path: [N.E], solutionCost: Double, log: AStarLog)?
{
  var finishedNodes = Set<N>()
  var fScore = [N: Double]()
  var gScore = [N: Double]()
  var predecesor = [N: (N,N.E)]()
  var openSet = OpenMinSet<N, Double>()
  //PriorityQueue<FScoreNode<N>>()
  var heapOrderId = 0
  var maxFrontierSize = 0
  var numberOfIterations = 0
  var numberOfInnerIterations = 0
  let initNodeFScore = initNode.heuristics
  openSet.push(initNode, score: initNodeFScore)
  //heapFrontier.push(FScoreNode(fScore: initNodeFScore, orderId: heapOrderId, node: initNode))
  maxFrontierSize += 1
  heapOrderId += 1
  fScore[initNode] = initNodeFScore
  gScore[initNode] = 0.0
  
  let verbose = true
  
  while let current = openSet.pop() {
    
    maxFrontierSize = max(maxFrontierSize, openSet.count + 1)
    
    if numberOfIterations % 1000 == 0 {
      if finishedNodes.count > maxSetSize || openSet.count > maxSetSize {
        print("Reached maximum set size \(maxSetSize). Terminating.")
        return nil
      }
    }
    
    //let current = minVertex.node
    if verbose && numberOfIterations % 100 == 0 {
      print("Iteration: \(numberOfIterations) Finished set size: \(finishedNodes.count) Frontier size: \(openSet.count) F-score: \(fScore[current]!) Cost: \(gScore[current]!)")
      let h = current.heuristics
      print(h)
    }
    
    if let checkContinueCount = checkContinueCount,
      numberOfIterations % checkContinueCount == 0,
      let continueFunction = continueFunction,
      !continueFunction()
    {
      if verbose {
        print("ASTAR planner terminated.")
      }
      return nil
    }
    
    if current.final {
      let finalCost = gScore[current]!
      if verbose {
        print("Final state found")
        print("Iterations: \(numberOfIterations) Inner iterations, \(numberOfInnerIterations) Finished set size: \(finishedNodes.count) Frontier size: \(openSet.count) F-score: \(fScore[current]!) Cost: \(finalCost)")
      }
      let log = AStarLog(
        closedSetSize: finishedNodes.count,
        maxOpenSetSize: maxFrontierSize,
        numberOfIterations: numberOfIterations,
        numberOfInnerIterations: numberOfIterations,
        solutionCost: gScore[current]!,
        solutionFScore: fScore[current]!)
      return (
        solution: current,
        path: reconstructPath(to: current, predecesor: predecesor),
        solutionCost: finalCost,
        log: log)
    }
    finishedNodes.insert(current)
    numberOfIterations += 1
    
    if let pruneFunction = pruneFunction, pruneFunction(current) {
      continue
    }
    
    let actions = current.outgoingEdges
    for action in actions {
      numberOfInnerIterations += 1
      let (neighbor, transitionCost) = current.neighbor(connectedBy: action)!
      let valid = true
      let contained = finishedNodes.contains(neighbor)
      if valid && !contained {
        let tentativeGScore = gScore[current]! + transitionCost
        if tentativeGScore < gScore[neighbor] ?? Double.infinity {
          gScore[neighbor] = tentativeGScore
          predecesor[neighbor] = (current, action)
          let heuristicValue = neighbor.heuristics
          let newFScore = tentativeGScore + heuristicValue
          fScore[neighbor] = newFScore
          if openSet.contains(neighbor) {
            openSet.decreaseKey(neighbor, to: newFScore)
          } else {
            openSet.push(neighbor, score: newFScore)
            //heapFrontier.push(FScoreNode(fScore: newFScore, orderId: heapOrderId, node: neighbor))
            heapOrderId += 1
          }
        }
      }
    }
  }
  return nil
}

fileprivate func reconstructPath<N: AStarNode>(to state: N, predecesor: [N: (N,N.E)]) -> [N.E] {
  var path = [N.E]()
  var current = state
  while let (previousNode, actionsTo) = predecesor[current] {
    path.append(actionsTo)
    current = previousNode
  }
  path.reverse()
  return path
}

//fileprivate struct FScoreNode<N: AStarNode> : Hashable, Comparable {
//  static func < (lhs: FScoreNode<N>, rhs: FScoreNode<N>) -> Bool {
//    return lhs.fScore < rhs.fScore || ( lhs.fScore == rhs.fScore && lhs.orderId < rhs.orderId )
//  }
//
//  static func == (lhs: FScoreNode<N>, rhs: FScoreNode<N>) -> Bool {
//    return lhs.fScore == rhs.fScore && lhs.orderId == rhs.orderId
//  }
//
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(fScore)
//    hasher.combine(orderId)
//  }
//
//  let fScore : Double
//  let orderId : Int
//  let node : N
//}

public struct AStarLog: CustomStringConvertible {
  public let closedSetSize : Int
  public let maxOpenSetSize : Int
  public let numberOfIterations : Int
  public let numberOfInnerIterations : Int
  public let solutionCost : Double
  public let solutionFScore : Double
  public var description: String {
    return "Iterations, \(numberOfIterations), Inner iterations, \(numberOfInnerIterations), Finished set size, \(closedSetSize), Max Frontier size, \(maxOpenSetSize), F-score, \(solutionFScore), Cost, \(solutionCost)"
  }
}
