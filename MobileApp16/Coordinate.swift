//
//  Coordinate.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 02/11/16.
//
//

import Foundation

struct Coordinate {
    var row: Int
    var col: Int
    
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    
    
    func getNorth() -> Coordinate { return Coordinate(row-1, col) }
    func getEast() -> Coordinate { return Coordinate(row, col+1) }
    func getSouth() -> Coordinate { return Coordinate(row+1, col) }
    func getWest() -> Coordinate { return Coordinate(row, col-1) }
    func getNorthEast() -> Coordinate { return Coordinate(row-1, col+1) }
    func getSouthEast() -> Coordinate { return Coordinate(row+1, col+1) }
    func getSouthWest() -> Coordinate { return Coordinate(row+1, col-1) }
    func getNorthWest() -> Coordinate { return Coordinate(row-1, col-1) }
    
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "(\(row),\(col))"
    }
}

extension Coordinate: Equatable, Hashable {
    var hashValue: Int {
        return row.hashValue ^ col.hashValue
    }

    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
}
