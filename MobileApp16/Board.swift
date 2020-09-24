//
//  Board.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 31/10/16.
//
//

import Foundation


struct Cell {
    let isSpecial: Bool
    var piece: Piece?
    
    init(isSpecial: Bool = false, piece: Piece? = nil) {
        self.isSpecial = isSpecial
        self.piece = piece
    }
}

struct Matrix {
    let rows: Int, columns: Int
    var grid: [Cell]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: Cell(), count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Cell {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }

}

struct Board {
    internal var matrix: Matrix
    var specialCells: [Cell] {
        return self.matrix.grid.filter({ cell in return cell.isSpecial })
    }
    var specialCellsCoordinates: Set<Coordinate> {
        var special: Set<Coordinate> = []
        for r in 0..<matrix.rows {
            for c in 0..<matrix.columns {
                if matrix[r,c].isSpecial {
                    special.insert(Coordinate(r, c))
                }
            }
        }
        return special
    }
    var freeCellsCoordinates: Set<Coordinate> {
        var free: Set<Coordinate> = []
        for r in 0..<matrix.rows {
            for c in 0..<matrix.columns {
                if matrix[r,c].piece == nil {
                    free.insert(Coordinate(r, c))
                }
            }
        }
        return free
    }
    
    
    /// Create a new board. If no specialCells and pieces arguments are passed, the initialiser will create an empty board.
    ///
    /// - parameter rows:         number of rows of the matrix
    /// - parameter columns:      number of columns of the board
    /// - parameter specialCells: array of Coordinate representing special cells
    /// - parameter pieces:       array of Piece objects to be placed on the board
    init(rows: Int, columns: Int, specialCells: [Coordinate] = [], pieces: [Piece] = []) {
        matrix = Matrix(rows: rows, columns: columns)
        // Set special cells
        for cellCoord in specialCells {
            guard coordinateIsValid(cellCoord) else { continue }
            self.matrix[cellCoord.row, cellCoord.col] = Cell(isSpecial: true)
        }
        // Placing pieces respecting their initial position
        for piece in pieces {
            let row = piece.initialPosition.row
            let col = piece.initialPosition.col
            
            guard matrix.indexIsValid(row: row, column: col) else { continue }
            self.matrix[row, col].piece = piece
        }
    }
    
    
    /// Create a new square board. If no specialCells and pieces arguments are passed, the initialiser will create an empty board.
    ///
    /// - parameter edge:         dimension of the edge of the square matrix
    /// - parameter specialCells: array of Coordinate representing special cells
    /// - parameter pieces:       array of Piece objects to be placed on the board
    init(edge: Int, specialCells: [Coordinate] = [], pieces: [Piece] = []) {
        matrix = Matrix(rows: edge, columns: edge)
        // Set special cells
        for cellCoord in specialCells {
            guard coordinateIsValid(cellCoord) else { continue }
            self.matrix[cellCoord.row, cellCoord.col] = Cell(isSpecial: true)
        }
        // Placing pieces respecting their initial position
        for piece in pieces {
            let row = piece.initialPosition.row
            let col = piece.initialPosition.col
            
            guard matrix.indexIsValid(row: row, column: col) else { continue }
            self.matrix[row, col].piece = piece
        }
    }
    
    
    /// Control coordinate validity
    func coordinateIsValid(_ coordinate: Coordinate) -> Bool {
        
        if coordinate.row >= self.matrix.rows || coordinate.row < 0 { return false }
        if coordinate.col >= self.matrix.columns || coordinate.col < 0 { return false }
        
        return true
    }
    
    
    /// Gives a reference to the Piece located at the given coordinates
    ///
    /// - parameter at: coordinates of the cell at which the piece will be picked
    ///
    /// - returns: a reference to the piece, nil if no piece is present or invalid coordinates are provided
    func getPiece(at: Coordinate) -> Piece? {
        guard coordinateIsValid(at) else { return nil }
        return matrix[at.row, at.col].piece
    }
    
    
    /// Find the current coordinates of the given piece
    func getPieceCoordinate(piece: Piece) -> Coordinate? {
        for r in 0..<matrix.rows {
            for c in 0..<matrix.columns {
                if matrix[r,c].piece === piece {
                    return Coordinate(r,c)
                }
            }
        }
        
        return nil
    }
    
    
    /// Place a piece on this board.
    ///
    /// - parameter piece: the Piece object to be placed
    /// - parameter at:    the target coordinates
    /// - parameter overwrite: if true overwrite the current piece occupying the same cell (default is false)
    ///
    /// - returns: true if piece has been placed, false if the cell was already occupied and no force option selected
    mutating func placePiece(piece: Piece, at: Coordinate, overwrite: Bool = false) -> Bool {
        guard coordinateIsValid(at) else { return false }
        if (overwrite || self.matrix[at.row, at.col].piece == nil ) {
            self.matrix[at.row, at.col].piece = piece
            return true
        }
        return false
    }
    
    
    /// Remove the piece from the cell at the given coordinates
    ///
    /// - Parameter from: coordinates of the cell where to remove the piece
    /// - Returns: true if the piece has been removed, false if invalid coordinates or cell already empty
    mutating func removePiece (from: Coordinate) -> Bool {
        guard coordinateIsValid(from) else { return false }
        if self.matrix[from.row, from.col].piece != nil {
            self.matrix[from.row, from.col].piece = nil
            return true
        }
        return false
    }
    
    
    /// Returns true if the cell at cellCoordinate is special
    func isSpecialCell(cellCoordinate c: Coordinate) -> Bool {
        if coordinateIsValid(c) && self.matrix[c.row, c.col].isSpecial { return true }
        return false
    }
    
    
    /// Simply moves a piece from one cell to another one,
    /// without considering game's logic or actions.
    ///
    /// - Parameters:
    ///   - startingCoordinate: coordinates of the piece to be moved
    ///   - endingCoordinate: destination coordinates (must correspond to an empty cell)
    /// - Returns: true if the move was successful,
    ///            false if coordinates were invalid or the destination cell was already occupied
    mutating func movePiece(startingCoordinate: Coordinate, endingCoordinate: Coordinate) -> Bool {
        guard coordinateIsValid(startingCoordinate) &&
              coordinateIsValid(endingCoordinate) else { return false }
        
        if let startingPiece = getPiece(at: startingCoordinate) {
            // There shouldn't be a piece in the ending coordinate
            if placePiece(piece: startingPiece, at: endingCoordinate, overwrite: false) &&
               removePiece(from: startingCoordinate) { return true }
        }
        
        return false
    }
    
    
    /// This function computes all the possible moves allowed to a particular piece
    /// on the basis of its movement properties and the current state of the board.
    ///
    /// - parameter coordinate: coordinates of the piece that want to move
    ///
    /// - returns: The array of coordinates in which the piece can move (can be empty)
    func allowedMoves(coordinate pieceCoor: Coordinate) -> [Coordinate] {
        
        // Check if the passed coordinate is valid otherwise return
        guard coordinateIsValid(pieceCoor) else { return [] }
        // Check if the cell at the given coordinates actually holds a piece
        guard let higlightedPiece = getPiece(at: pieceCoor) else { return [] }
        
        
        // ###
        // Recursive function which scans the board matrix
        func allowedMovesRecursive(coord: Coordinate, prevCoord: Coordinate, hopsLeft: Int) -> [Coordinate] {
            
            // Check if the passed coordinate is valid and that hops left is at least 0, otherwise return
            guard coordinateIsValid(coord) && hopsLeft >= 0 else { return [] }
            
            /// Array of coordinates corresponding to cells in which movement is allowed.
            var cellsFound: [Coordinate] = []
            
            // If we returned to the starting cell then do not check the presence of a piece
            if coord != pieceCoor {
                // If there is a piece on this coordinate, check its color
                if let foundPiece = getPiece(at: coord) {
                    if foundPiece.color == higlightedPiece.color {  // Ally Piece
                        if higlightedPiece.movement.movementType == .walk {
                            return cellsFound // []
                        }
                    } else {                                        // Enemy Piece
                        cellsFound += [coord]
                        if higlightedPiece.movement.movementType == .walk {
                            return cellsFound // [c]
                        }
                    }
                } else { // Empty cell
                    cellsFound += [coord]
                }
            }
            
            // At this point, if hops left is 0 we can avoid exploring further more
            if hopsLeft == 0 { return cellsFound }
            
            // Here we start exploring the cells around us
            // If the piece can move straight or in any direction explore north, east, south and west
            if higlightedPiece.movement.direction == .straight || higlightedPiece.movement.direction == .any {
                let nextCoordinates = [coord.getNorth(), coord.getEast(), coord.getSouth(), coord.getWest()]
                for nextCoord in nextCoordinates {
                    // Optimization. Not going back on our steps
                    if (nextCoord != prevCoord) {
                        cellsFound += allowedMovesRecursive(coord: nextCoord, prevCoord: coord, hopsLeft: hopsLeft-1)
                    }
                }
            }
            // If the piece can move diagonally or in any direction explore north-east, south-east, south-west and north-west
            if higlightedPiece.movement.direction == .diagonal || higlightedPiece.movement.direction == .any {
                let nextCoordinates = [coord.getNorthEast(), coord.getSouthEast(), coord.getSouthWest(), coord.getNorthWest()]
                for nextCoord in nextCoordinates {
                    // Optimization. Not going back on our steps
                    if (nextCoord != prevCoord) {
                        cellsFound += allowedMovesRecursive(coord: nextCoord, prevCoord: coord, hopsLeft: hopsLeft-1)
                    }
                }
            }
            
            return cellsFound.unique
        }
        // ###

        
        return allowedMovesRecursive(coord: pieceCoor, prevCoord: pieceCoor, hopsLeft: higlightedPiece.movement.range)
    }
    

    /// This function computes all the possible coordinates of attack for a particular piece
    /// on the basis of its attacking properties and the current state of the board.
    ///
    /// - parameter coordinate: coordinates of the piece that want to attack
    ///
    /// - returns: The array of coordinates in which the piece can attack (can be empty)
    func allowedAttacks(coordinate pieceCoord: Coordinate) -> [Coordinate] {
        
        // Check if the passed coordinate is valid otherwise return
        guard coordinateIsValid(pieceCoord) else { return [] }
        // Check if the cell at the given coordinates actually holds a piece
        guard let higlightedPiece = getPiece(at: pieceCoord) else { return [] }
        // Check if the piece has attack capabilities
        guard higlightedPiece.attack.range > 0, let pieceAttackDirection = higlightedPiece.attack.direction else { return [] }
        
        enum Directions {
            case North, East, South, West, NorthEast, SouthEast, SouthWest, NorthWest
        }
        
        // ###
        // Recursive function which scans the board matrix
        func allowedAttacksRecursive(coordinate coord: Coordinate, direction: Directions, hopsLeft: Int) -> [Coordinate] {
            
            // Check if the passed coordinate is valid and that hops left is at least 0, otherwise return
            guard coordinateIsValid(coord) && hopsLeft >= 0 else { return [] }
            
            // If there is a piece on this coordinate, check if it is an ally or an opponent
            if let foundPiece = getPiece(at: coord) {
                if foundPiece.color == higlightedPiece.color {  // Ally Piece
                    return [ ]
                } else {                                        // Enemy Piece
                    return [coord]
                }
            }
            
            // At this point, if hops left is 0 we can avoid exploring further more
            if hopsLeft == 0 { return [] }
            
            /// Coordinates of cells found in this branch for which the attack is allowed.
            var cellsFound: [Coordinate] = []
            
            // Here we start exploring the cells around us
            // An attack can be performed keeping the same direction for the entire range,
            // so we follow the direction previously undertaken.
            switch direction {
            case .North:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getNorth(), direction: direction, hopsLeft: hopsLeft-1)
            case .East:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getEast(), direction: direction, hopsLeft: hopsLeft-1)
            case .South:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getSouth(), direction: direction, hopsLeft: hopsLeft-1)
            case .West:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getWest(), direction: direction, hopsLeft: hopsLeft-1)
            case .NorthEast:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getNorthEast(), direction: direction, hopsLeft: hopsLeft-1)
            case .SouthEast:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getSouthEast(), direction: direction, hopsLeft: hopsLeft-1)
            case .SouthWest:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getSouthWest(), direction: direction, hopsLeft: hopsLeft-1)
            case .NorthWest:
                cellsFound += allowedAttacksRecursive(coordinate: coord.getNorthWest(), direction: direction, hopsLeft: hopsLeft-1)
            }
            
            return cellsFound.unique
        }
        // ###
        
        /// Coordinates of cells for which the attack is allowed
        var attackCells: [Coordinate] = []
        
        let attackRange = higlightedPiece.attack.range
        
        // Cells exploration depends on the attack direction specified for the highlighted piece
        switch pieceAttackDirection {
        case .straight:
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getNorth(), direction: .North, hopsLeft: attackRange-1)
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getEast(), direction: .East, hopsLeft: attackRange-1)
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getSouth(), direction: .South, hopsLeft: attackRange-1)
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getWest(), direction: .West, hopsLeft: attackRange-1)
        case .diagonal:
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getNorthEast(), direction: .NorthEast, hopsLeft: attackRange-1)
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getSouthEast(), direction: .SouthEast, hopsLeft: attackRange-1)
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getSouthWest(), direction: .SouthWest, hopsLeft: attackRange-1)
            attackCells += allowedAttacksRecursive(coordinate: pieceCoord.getNorthWest(), direction: .NorthWest, hopsLeft: attackRange-1)
        }
        
        
        return attackCells.unique
    }
    
    mutating func recoverState(state: String, pieces: [Piece]) {
        let total_pieces = 16

        var pieceCount: Int = 0
        
        // Resetting current vitality and frozen turns left counter
        for piece in pieces {
            piece.currentVitality = 0
            piece.frozenTurnsLeft = 0
        }
        
        // PLACING PIECES ON BOARD AD UPDATING THEIR VITALITY
        for col in 0 ..< self.matrix.columns {
            for row in 0 ..< self.matrix.rows {
                let boardIndex = (row * self.matrix.columns) + col
                let pieceIdChar = Character(state[boardIndex])
                
                if pieceIdChar == "0" {
                    matrix[row, col].piece = nil
                } else if let index = pieces.index(where: { p in p.id == pieceIdChar }) {
                    pieceCount += 1
                    // Place piece on the board
                    self.matrix[row,col].piece = pieces[index]
                    // Setting the vitality
                    let vitalityIndex = self.matrix.columns * self.matrix.rows + (pieceCount - 1)
                    let vitality = Int(state[vitalityIndex])!
                    pieces[index].currentVitality = vitality
                }
            }
        }
        
        // FROZEN TURNS
        let frozenTurnsBaseIndex = self.matrix.columns * self.matrix.rows + total_pieces
        for turnCount in 0...1 {
            let pieceIdChar = Character(state[frozenTurnsBaseIndex + turnCount*2])
            if let index = pieces.index(where: { p in p.id == pieceIdChar }) {
                // Setting the frozen turns counter
                let remainingTurns = Int(state[frozenTurnsBaseIndex + turnCount*2 + 1])!
                pieces[index].frozenTurnsLeft = remainingTurns
            }
        }
    }
    
}

extension Board: CustomStringConvertible {
    var description: String {
        var description: String = ""
        for row in 0 ..< self.matrix.rows {
            for col in 0 ..< self.matrix.columns {
                if let foundPiece = self.matrix[row,col].piece {
                    if foundPiece.name.lengthOfBytes(using: .ascii) > 0 {
                        description += foundPiece.color == .white
                                        ? foundPiece.name[0].uppercased()
                                        : foundPiece.name[0].lowercased()
                    } else {
                        description += "-"
                    }
                } else {
                    description += "0"
                }
            }
        }
        return description
    }
    
    /// Creates a String description of the elements of the Board:
    ///     -matrix with position of the pieces in row order
    ///     -vitality of the pieces in column order
    ///     -frozen pieces information: rowCoordinate, columnCoordinate, frozenTurnsLeft
    var fullDescription: String {
        var boardDescription = ""
        var whiteFrozenPiece = "000"
        var blackFrozenPiece = "000"
        
        //Double for loops to scan the matrix row by row to fill the string with pieces representing char ordering by row
        for rowCounter in 0 ..< self.matrix.rows {
            for columnCounter in 0 ..< self.matrix.columns {
                if let currentPiece = self.matrix[rowCounter, columnCounter].piece {
                    //Checks if the current piece is in frozen state and if so, depending on the color of the piece it creates a string containing the information of the frozen piece
                    if (currentPiece.isFrozen) {
                        if (currentPiece.color == .white) {
                            whiteFrozenPiece = "\(columnCounter+1)\(rowCounter+1)\(currentPiece.frozenTurnsLeft)"
                        } else {
                            blackFrozenPiece = "\(columnCounter+1)\(rowCounter+1)\(currentPiece.frozenTurnsLeft)"
                        }
                    }
                    
                    //Takes the first letter of the name of the current piece and append it to the string uppered or lowered case depending on the piece type and color
                    if currentPiece.name.lengthOfBytes(using: .ascii) > 0 {
                        if (currentPiece.color == .white) {
                            boardDescription.append(currentPiece.name[0].uppercased())
                        } else {
                            boardDescription.append(currentPiece.name[0].lowercased())
                        }
                    } else {
                        boardDescription.append("-")
                    }
                } else {
                    //In case there is no piece in the cells we pad the string with a 0
                    boardDescription.append("0")
                }
            } // end for columnCounter
        } // end for rowCounter
        
        boardDescription.append(vitalityString)
        boardDescription.append(whiteFrozenPiece)
        boardDescription.append(blackFrozenPiece)
        
        return boardDescription
    }
    
    var stateDescription: String {
        var boardDescription: String = ""
        var whiteFrozenPiece = "00"
        var blackFrozenPiece = "00"
        
        for row in 0 ..< self.matrix.rows {
            for col in 0 ..< self.matrix.columns {
                if let foundPiece = self.matrix[row,col].piece {
                    boardDescription.append(foundPiece.id)
                    if foundPiece.isFrozen {
                        if foundPiece.color == .white {
                            whiteFrozenPiece = "\(foundPiece.id)\(foundPiece.frozenTurnsLeft)"
                        } else {
                            blackFrozenPiece = "\(foundPiece.id)\(foundPiece.frozenTurnsLeft)"
                        }
                    }
                } else {
                    boardDescription += "0"
                }
            }
        }
        
        boardDescription.append(vitalityString)
        boardDescription.append(whiteFrozenPiece)
        boardDescription.append(blackFrozenPiece)
        
        return boardDescription
    }
    
    var vitalityString: String {
        let total_pieces = 16
        
        var vitality = ""
        var alivePieces = 0
        
        //Double for loops to scan the matrix column by column to fill the string with vitality ordering by column
        for columnCounter in 0 ..< self.matrix.columns {
            for rowCounter in 0 ..< self.matrix.rows {
                if let currentPiece = matrix[rowCounter, columnCounter].piece {
                    vitality.append(String(currentPiece.currentVitality))
                    alivePieces = alivePieces + 1
                }
            }
        }
        let deadPieces = total_pieces - alivePieces
        
        //Padding with a 0 for each dead piece in the game
        for _ in 0 ..< deadPieces {
            vitality.append("0")
        }
        
        return vitality
    }
    
}
