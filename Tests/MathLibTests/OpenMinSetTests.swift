import XCTest
@testable import MathLib

final class OpenMinSetTests: XCTestCase {
  func testPushPop() {
    var openSet = OpenMinSet<Int, Double>()
    var testArray = [(Int,Double)]()
    var scores = [Int: Double]()
    for i in 0..<100000 {
      let score = Double.random(in: 0...1000000)
      testArray.append((i, score))
      scores[i] = score
    }
    
    for (element, score) in testArray {
      openSet.push(element, score: score)
      if element.isMultiple(of: 10) {
        let _ = openSet.pop()
      }
    }
    
    var lastScore = 0.0
    
    while let element = openSet.pop() {
      if scores[element]! < lastScore {
        XCTAssert(false)
      }
      lastScore = scores[element]!
    }
    XCTAssert(true)
  }
  
  func testDecreaseKey() {
    var openSet = OpenMinSet<Int, Double>()
    var testArray = [(Int,Double)]()
    var scores = [Int: Double]()
    for i in 0..<100000 {
      let score = Double.random(in: 0...1000000)
      testArray.append((i, score))
      scores[i] = score
    }
    
    for (element, score) in testArray {
      openSet.push(element, score: score)
    }
    
    for (element, _) in testArray {
      openSet.decreaseKey(element, to: -1.0)
      let popedElement = openSet.pop()!
      XCTAssert(element == popedElement)
    }
  }
  
  func testIncreaseKey() {
    var openSet = OpenMinSet<Int, Double>()
    var testArray = [(Int,Double)]()
    var scores = [Int: Double]()
    for i in 0..<100000 {
      let score = Double.random(in: 0...1000000)
      testArray.append((i, score))
      scores[i] = score
    }
    
    for (element, score) in testArray {
      openSet.push(element, score: score)
    }
    
    for (element, _) in testArray {
      let newScore = 2000000.0 - Double(element)
      openSet.increaseKey(element, to: newScore)
    }
    
    var lastElement = 100000
    while let element = openSet.pop() {
      if element > lastElement {
        XCTAssert(false)
      }
      lastElement = element
    }
  }
}
