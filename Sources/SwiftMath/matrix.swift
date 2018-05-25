//
//  matrix.swift
//  SwiftMath
//
//  Created by Pavel Rytir on 5/24/18.
//

import Foundation


// rows flattened representation
public struct Matrix {
    public init(rows: Int, columns: Int, grid: [Double]) {
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    public let rows: Int, columns: Int
    public var grid: [Double]
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    public func deepTranspose() -> Matrix {
        var result = Matrix(rows: self.columns, columns: self.rows)
        for row in 0..<self.rows {
            for column in 0..<self.columns {
                result[column, row] = self[row,column]
            }
        }
        return result
    }
}
