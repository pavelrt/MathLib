import XCTest
@testable import MathLib

final class DiGraphTests: XCTestCase {
    
    func testDijkstraTestPath() {
        let (path, start, end) = createDiPath(length: 1000)
        let (distances, paths) = findShortestPathsDijkstra(in: path, sourceId: start.id, pathTo: [end.id], lengths: { _ in return 1.0 })
        
        let distanceToEnd = distances[end.id]!
        XCTAssertEqual(distanceToEnd, 1000.0)
        XCTAssertEqual(paths[end.id]!.count, 1000) // Number of vertices on the path
    }

    
    func testDijkstraTestCircuit() {
        let circuit = createDiCircuit(length: 1000)
        let v1 = circuit.diVertices.first!
        let inEdge = circuit.incomingNeighbors(of: v1.key).first!.edge
        let v2Id = inEdge.start
    
        let (distances, paths) = findShortestPathsDijkstra(in: circuit, sourceId: v1.key, pathTo: [v2Id], lengths: { _ in return 1.0 })
        
        let distanceToEnd = distances[v2Id]!
        XCTAssertEqual(distanceToEnd, 999.0)
        XCTAssertEqual(paths[v2Id]!.count, 999) // Number of vertices on the path
    }
    
    func testCreateGrid1() {
        let (grid, _) = createDiGrid(dimensions: 10)
        XCTAssertEqual(grid.numberOfVertices, 10)
        XCTAssertEqual(grid.numberOfEdges, 18)
    }
    func testCreateGrid2() {
        let (grid, _) = createDiGrid(dimensions: 10, 10)
        XCTAssertEqual(grid.numberOfVertices, 100)
        XCTAssertEqual(grid.numberOfEdges, 18 * 10 + 18 * 10)
    }
    func testCreateGrid3() {
        let (grid, _) = createDiGrid(dimensions: 10, 10, 10)
        XCTAssertEqual(grid.numberOfVertices, 1000)
        XCTAssertEqual(grid.numberOfEdges, ((18 * 10 + 18 * 10) * 10) + (10 * 18 * 10))
    }
    func testDijkstraGrid3() {
        let (grid, indexer) = createDiGrid(dimensions: 10, 10, 10)
        let start = indexer([0,0,0])
        let end = indexer([9,9,9])
        let (distances, paths) = findShortestPathsDijkstra(in: grid, sourceId: start, pathTo: [end], lengths: { _ in return 1.0 })
        let distanceToEnd = distances[end]!
        XCTAssertEqual(distanceToEnd, 3 * 9.0)
        XCTAssertEqual(paths[end]!.count, 3 * 9) // Number of vertices on the path
    }
    
    

    static var allTests = [
        ("testDijkstraTestPath", testDijkstraTestPath),
        ("testDijkstraTestCircuit", testDijkstraTestCircuit),
        ("testCreateGrid1", testCreateGrid1),
        ("testCreateGrid2", testCreateGrid2),
        ("testCreateGrid3", testCreateGrid3),
        ("testDijkstraGrid3", testDijkstraGrid3),
    ]
}
