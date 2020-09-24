//
//  BoardParser.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 23/11/16.
//
//

import Foundation

enum ParserError: Error {
    case InvalidCoordinate
    case InvalidStringLenght
    case InvalidBoardCharacter
    case InvalidReuseOfBoardCharacter
}

func legacyBoardParser(_ boardDescription: String) throws -> Board {
    let numberOfChars = boardDescription.lengthOfBytes(using: .ascii)
    let edge = Int(sqrt(Double(numberOfChars)))
    
    guard numberOfChars == edge * edge else { throw ParserError.InvalidStringLenght }
    
    var pieces = try getPiecesFromJson()
    var board = Board(edge: edge)
    
    for col in 0 ..< edge {
        for row in 0 ..< edge {
            let index = (row * edge) + col
            let cellChar = boardDescription[index]
            
            var pieceName: String
            var pieceColor: Color
            
            switch cellChar {
            case "G","g":   // Giant
                pieceName = "Giant"
                pieceColor = cellChar == "G" ? Color.white : Color.black
            case "D","d":   // Dragon
                pieceName = "Dragon"
                pieceColor = cellChar == "D" ? Color.white : Color.black
            case "M","m":   // Mage
                pieceName = "Mage"
                pieceColor = cellChar == "M" ? Color.white : Color.black
            case "A","a":   // Archer
                pieceName = "Archer"
                pieceColor = cellChar == "A" ? Color.white : Color.black
            case "S","s":   // Squire
                pieceName = "Squire"
                pieceColor = cellChar == "S" ? Color.white : Color.black
            case "K","k":   // Knight
                pieceName = "Knight"
                pieceColor = cellChar == "K" ? Color.white : Color.black
            case "0":       // Empty-cell
                // Continue to the next row
                continue
            default:
                throw ParserError.InvalidBoardCharacter
            }
            
            if let piece = pieces.filter({ piece in piece.name == pieceName && piece.color == pieceColor }).first {
                // Placing piece on the board
                guard board.placePiece(piece: piece, at: Coordinate(row, col), overwrite: false) else {
                    throw ParserError.InvalidCoordinate
                }
                pieces = pieces.filter({ $0 !== piece })
            } else {
                throw ParserError.InvalidReuseOfBoardCharacter
            }

        }
    }
    
    return board
}
