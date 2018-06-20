import XCTest
@testable import SwiftMath

final class SwiftMathTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftMath().text, "Hello, World!")
    }
    
    func testDijkstraTestPath() {
        let (path, start, end) = createDiPath(length: 1000)
        let (distances, paths) = shortestPathsDijkstra(in: path, sourceId: start.id, pathTo: [end.id], lengths: { _ in return 1.0 })
        
        let distanceToEnd = distances[end.id]!
        XCTAssertEqual(distanceToEnd, 1000.0)
        XCTAssertEqual(paths[end.id]!.count, 1000)
    }

    
    func testDijkstraTestCircuit() {
        let circuit = createDiCircuit(length: 1000)
        let v1 = circuit.vertices.first!
        let inEdge = circuit.edges[v1.value.inEdges.first!]
        let v2Id = inEdge!.start
    
        let (distances, paths) = shortestPathsDijkstra(in: circuit, sourceId: v1.key, pathTo: [v2Id], lengths: { _ in return 1.0 })
        
        let distanceToEnd = distances[v2Id]!
        XCTAssertEqual(distanceToEnd, 999.0)
        XCTAssertEqual(paths[v2Id]!.count, 999)
    }
    
    func testCreateGrid1() {
        let (grid, _) = createDiGrid(dimensions: 10)
        XCTAssertEqual(grid.vertices.count, 10)
        XCTAssertEqual(grid.edges.count, 18)
    }
    func testCreateGrid2() {
        let (grid, _) = createDiGrid(dimensions: 10, 10)
        XCTAssertEqual(grid.vertices.count, 100)
        XCTAssertEqual(grid.edges.count, 18 * 10 + 18 * 10)
    }
    func testCreateGrid3() {
        let (grid, _) = createDiGrid(dimensions: 10, 10, 10)
        XCTAssertEqual(grid.vertices.count, 1000)
        XCTAssertEqual(grid.edges.count, ((18 * 10 + 18 * 10) * 10) + (10 * 18 * 10))
    }
    func testDijkstraGrid3() {
        let (grid, indexer) = createDiGrid(dimensions: 10, 10, 10)
        let start = indexer([0,0,0])
        let end = indexer([9,9,9])
        let (distances, paths) = shortestPathsDijkstra(in: grid, sourceId: start, pathTo: [end], lengths: { _ in return 1.0 })
        let distanceToEnd = distances[end]!
        XCTAssertEqual(distanceToEnd, 3 * 9.0)
        XCTAssertEqual(paths[end]!.count, 3 * 9)
    }
    
    

    static var allTests = [
        ("testExample", testExample),
        ("testDijkstraTestPath", testDijkstraTestPath),
    ]
}
