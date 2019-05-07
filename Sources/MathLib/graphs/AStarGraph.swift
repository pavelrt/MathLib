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


public func aStarSearch<N: AStarNode>(from initNode: N, pruneFunction: ((N) -> Bool)?, continueFunction: (() -> Bool)? = nil, checkContinueCount: Int? = nil , maxSetSize: Int = 2_000_000, verbose: Bool = false) -> (solution: N, path: [N.E], solutionCost: Double)? {
    
    //---------
    
    var finishedNodes = Set<N>()
    var fScore = [N: Double]()
    var gScore = [N: Double]()
    var predecesor = [N: (N,N.E)]()
    var heapFrontier = PriorityQueue<FScoreNode<N>>()
    var heapOrderId = 0
    var numberOfIterations = 0
    var numberOfInnerIterations = 0
    let initNodeFScore = initNode.heuristics
    heapFrontier.push(FScoreNode(fScore: initNodeFScore, orderId: heapOrderId, node: initNode))
    heapOrderId += 1
    fScore[initNode] = initNodeFScore
    gScore[initNode] = 0.0
    
    let verbose = true
    
    while let minVertex = heapFrontier.pop() {
        
        if numberOfIterations % 1000 == 0 {
            if finishedNodes.count > maxSetSize || heapFrontier.count > maxSetSize {
                print("Reached maximum set size \(maxSetSize). Terminating.")
                return nil
            }
        }
        
        let current = minVertex.node
        if verbose && numberOfIterations % 100 == 0 {
            print("Iteration: \(numberOfIterations) Finished set size: \(finishedNodes.count) Frontier size: \(heapFrontier.count) F-score: \(minVertex.fScore) Cost: \(gScore[current]!)")
            let h = current.heuristics
            print(h)
        }
        
        if let checkContinueCount = checkContinueCount, numberOfIterations % checkContinueCount == 0, let continueFunction = continueFunction, !continueFunction() {
            if verbose {
                print("ASTAR planner terminated.")
            }
            return nil
        }
        
        if current.final {
            let finalCost = gScore[current]!
            if verbose {
                print("Final state found")
                print("Iterations: \(numberOfIterations) Inner iterations, \(numberOfInnerIterations) Finished set size: \(finishedNodes.count) Frontier size: \(heapFrontier.count) F-score: \(minVertex.fScore) Cost: \(finalCost)")
            }
            //let logItem = "Iterations, \(numberOfIterations), Inner iterations, \(numberOfInnerIterations), Finished set size, \(finishedNodes.count), Frontier size, \(heapFrontier.count), F-score, \(minVertex.fScore), Cost, \(gScore[current]!)"
            return (current, reconstructPath(to: current, predecesor: predecesor), finalCost)
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
                let tentativeGScore = gScore[minVertex.node]! + transitionCost
                if tentativeGScore < gScore[neighbor] ?? Double.infinity {
                    gScore[neighbor] = tentativeGScore
                    let heuristicValue = neighbor.heuristics
                    let newFScore = tentativeGScore + heuristicValue
                    fScore[neighbor] = newFScore
                    heapFrontier.push(FScoreNode(fScore: newFScore, orderId: heapOrderId, node: neighbor))
                    heapOrderId += 1
                    predecesor[neighbor] = (current, action)
                }
            }
        }
    }
    return nil
    
    //--------
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

fileprivate struct FScoreNode<N: AStarNode> : Hashable, Comparable {
    static func < (lhs: FScoreNode<N>, rhs: FScoreNode<N>) -> Bool {
        return lhs.fScore < rhs.fScore || ( lhs.fScore == rhs.fScore && lhs.orderId < rhs.orderId )
    }
    
    static func == (lhs: FScoreNode<N>, rhs: FScoreNode<N>) -> Bool {
        return lhs.fScore == rhs.fScore && lhs.orderId == rhs.orderId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fScore)
        hasher.combine(orderId)
    }
    
    let fScore : Double
    let orderId : Int
    let node : N
}

