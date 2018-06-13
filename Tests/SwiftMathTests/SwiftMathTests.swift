import XCTest
@testable import SwiftMath

final class SwiftMathTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftMath().text, "Hello, World!")
    }
    
    func dijkstraTestPath() {
        let (path, start, end) = createPath(length: 100)
        let (distances, paths) = shortestPathsDijkstra(in: path, sourceId: start.id, pathTo: [end.id], lengths: { _ in return 1.0 })
        
        let distanceToEnd = distances[end.id]!
        XCTAssertEqual(distanceToEnd, 100.0)
        
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
