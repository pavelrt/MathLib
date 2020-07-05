//
//  matrix.swift
//  SwiftMath
//
//  Created by Pavel Rytir on 5/24/18.
//

import Foundation

/// Matrix of elements. Row flattened representation.
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

extension Matrix {
  public func applyElementwise(function: (Double) -> Double) -> Matrix {
    let newGrid = self.grid.map(function)
    return Matrix(rows: self.rows, columns: self.columns, grid: newGrid)
  }
  
  public static prefix func - (matrix: Matrix) -> Matrix {
    return matrix.applyElementwise { -$0 }
  }
  
  public static func * (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.applyElementwise { lhs * $0 }
  }
}

extension Matrix {
  public func appendBellow(matrix: Matrix) -> Matrix {
    guard self.columns == matrix.columns else {
      fatalError("Cannot append two matrices that have different number of rows")
    }
    var newGrid = self.grid
    newGrid.append(contentsOf: matrix.grid)
    return Matrix(rows: self.rows + matrix.rows, columns: self.columns, grid: newGrid)
  }
  public func appendRight(matrix: Matrix) -> Matrix {
    guard self.rows == matrix.rows else {
      fatalError("Cannot append two matrices that have different number of colums")
      
    }
    var newMatrix = Matrix(rows: self.rows, columns: self.columns + matrix.columns)
    for column in 0..<newMatrix.columns {
      for row in 0..<newMatrix.rows {
        newMatrix[row,column] = column < self.columns ?
          self[row,column] : matrix[row, column - self.columns]
      }
    }
    return newMatrix
  }
}

extension Matrix : CustomStringConvertible {
  public var description: String {
    var desc = ""
    for row in 0..<rows {
      for column in 0..<columns {
        let f = "5.2"
        let valStr = String(format: "%\(f)f", self[row, column])
        desc += valStr + " "
      }
      desc += "\n"
    }
    return desc
  }
  
  
}

extension Matrix : Codable {
  
}
