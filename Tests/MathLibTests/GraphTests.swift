//
//  GraphTests.swift
//  MathLibTests
//
//  Created by Pavel Rytir on 24/09/2018.
//

import Foundation

import XCTest
@testable import MathLib

final class GraphTests: XCTestCase {
    
    func testPath() {
        let (diPath, _, _) = createDiPath(length: 1000)
        let (path, _, _) = createPath(length: 1000)
        
        XCTAssertEqual(path.numberOfVertices, 1001)
        XCTAssertEqual(diPath.numberOfVertices, 1001)
    }
}
