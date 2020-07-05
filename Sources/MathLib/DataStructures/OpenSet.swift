//
//  OpenSet.swift
//  MathLib
//
//  Created by Pavel Rytir on 7/5/20.
//

import Foundation

/// Data structure for implementing open set in a* and Dijstra algorithms
/// openset[id] = score
/// T is the type of elements
/// S is the type of scores of elements
public struct OpenMinSet<T: Hashable, S: Comparable> { // openminset
  
  public private(set) var heap = [T]()
  public private(set) var scores = [T:S]()
  private var indexDictionary = [T:Int]()
  
  /// Creates a new OpenSet with the given ordering.
  ///
  /// - parameter order: A function that specifies whether its first argument should
  ///                    come after the second argument in the OpenSet.
  /// - parameter startingValues: An array of elements to initialize the OpenSet with.
  public init(startingValues: [T] = [], scores: [T:S]) {
    self.scores = scores
    
    // Based on "Heap construction" from Sedgewick p 323
    heap = startingValues
    for (i, element) in heap.enumerated() {
      indexDictionary[element] = i
    }
    var i = heap.count/2 - 1
    while i >= 0 {
      sink(i)
      i -= 1
    }
  }
  
  /// How many elements the OpenSet stores
  public var count: Int { return heap.count }
  
  /// true if and only if the OpenSet is empty
  public var isEmpty: Bool { return heap.isEmpty }
  
  /// Add a new element onto the OpenSet. O(lg n)
  ///
  /// - parameter element: The element to be inserted into the OpenSet.
  public mutating func push(_ element: T, score: S) {
    scores[element] = score
    heap.append(element)
    indexDictionary[element] = heap.count - 1
    swim(heap.count - 1)
  }
  
  /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
  ///
  /// - returns: The element with the highest priority in the OpenSet, or nil if the OpenSet is empty.
  public mutating func pop() -> T? {
    
    if heap.isEmpty { return nil }
    if heap.count == 1 { return heap.removeFirst() }  // added for Swift 2 compatibility
    // so as not to call swap() with two instances of the same location
    swap(0, heap.count - 1)
    let temp = heap.removeLast()
    indexDictionary.removeValue(forKey: temp)
    scores.removeValue(forKey: temp)
    sink(0)
    
    return temp
  }
  
  public func contains(_ element: T) -> Bool {
    indexDictionary[element] != nil
  }
  
  public mutating func decreaseKey(_ element: T, to newScore: S) {
    assert(scores[element]! >= newScore)
    scores[element] = newScore
    
  }
  
  /// Removes the first occurence of a particular item.
  /// Silently exits if no occurrence found.
  ///
  /// - parameter item: The item to remove the first occurrence of.
  public mutating func remove(_ item: T) {
    if let index = indexDictionary[item] {
      swap(index, heap.count - 1)
      heap.removeLast()
      indexDictionary.removeValue(forKey: item)
      scores.removeValue(forKey: item)
      if index < heap.count { // if we removed the last item, nothing to swim
        swim(index)
        sink(index)
      }
    }
  }
  
  /// Removes all occurences of a particular item. Finds it by value comparison using ==. O(n)
  /// Silently exits if no occurrence found.
  ///
  /// - parameter item: The item to remove.
  public mutating func removeAll(_ item: T) {
    var lastCount = heap.count
    remove(item)
    while (heap.count < lastCount) {
      lastCount = heap.count
      remove(item)
    }
  }
  
  /// Get a look at the current highest priority item, without removing it. O(1)
  ///
  /// - returns: The element with the highest priority in the OpenSet, or nil if the OpenSet is empty.
  public func peek() -> T? {
    return heap.first
  }
  
  /// Eliminate all of the elements from the OpenSet.
  public mutating func clear() {
    heap.removeAll(keepingCapacity: false)
    indexDictionary.removeAll()
  }
  
  private mutating func swap(_ index1: Int, _ index2: Int) {
    indexDictionary[heap[index1]] = index2
    indexDictionary[heap[index2]] = index1
    heap.swapAt(index1, index2)
  }
  
  private func ordered(_ e1: T, _ e2: T) -> Bool {
    scores[e1]! > scores[e2]!
  }
  
  // Based on example from Sedgewick p 316
  private mutating func sink(_ index: Int) {
    var index = index
    while 2 * index + 1 < heap.count {
      
      var j = 2 * index + 1
      
      if j < (heap.count - 1) && ordered(heap[j], heap[j + 1]) { j += 1 }
      if !ordered(heap[index], heap[j]) { break }
      
      swap(index, j)
      index = j
    }
  }
  
  // Based on example from Sedgewick p 316
  private mutating func swim(_ index: Int) {
    var index = index
    while index > 0 && ordered(heap[(index - 1) / 2], heap[index]) {
      swap((index - 1) / 2, index)
      index = (index - 1) / 2
    }
  }
}

//extension OpenSet : Equatable {
//  public static func == (lhs: OpenSet<T,S>, rhs: OpenSet<T,S>) -> Bool {
//    return lhs.heap == rhs.heap
//  }
//}

//extension OpenSet: Hashable where T : Hashable {
//  public func hash(into hasher: inout Hasher) {
//    hasher.combine(heap.hashValue)
//  }
//}

// MARK: - GeneratorType
extension OpenMinSet: IteratorProtocol {
  
  public typealias Element = T
  mutating public func next() -> Element? { return pop() }
}

// MARK: - SequenceType
extension OpenMinSet: Sequence {
  
  public typealias Iterator = OpenMinSet
  public func makeIterator() -> Iterator { return self }
}

// MARK: - CollectionType
extension OpenMinSet: Collection {
  
  public typealias Index = Int
  
  public var startIndex: Int { return heap.startIndex }
  public var endIndex: Int { return heap.endIndex }
  
  public subscript(i: Int) -> T { return heap[i] }
  
  public func index(after i: OpenMinSet.Index) -> OpenMinSet.Index {
    return heap.index(after: i)
  }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension OpenMinSet: CustomStringConvertible, CustomDebugStringConvertible {
  
  public var description: String { return heap.description }
  public var debugDescription: String { return heap.debugDescription }
}
