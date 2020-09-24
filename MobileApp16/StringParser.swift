//
//  StringParser.swift
//  MobileApp16
//
//  Created by manan tariq on 08/11/16.
//
//

import Foundation

enum Errors: Error {
    case InvalidPieceOrCoordinate
    case InvalidBoardCharacter
    case InvalidStringLenght
    case InvalidPlayerCharacter
    case InvalidBoardVitalityStringLenght
    case InvalidBoardFrozenPiecesStringLenght
    case InvalidBoardSpellStringLenght
    case InvalidMovesStringLenght
    case InvalidSpellCharacter
    case InvalidMoveCharacter
    case InvalidSpellPieceCoordinate
    
}

/// Function use for testing all parts of the game
func turnTest(testString: String) -> String {
    
    do {
        var game = try gameParser(testString: testString)
        if game.isGameEnded == true {
            game.changeTurn()
            if(game.winner == Color.white){
                return ("\(game.description)WHITE")
            }
            if(game.winner == Color.black){
                return "\(game.description)BLACK"
            }
            if(game.winner == nil){
                return "\(game.description)DRAW"
            }
        }
        return game.description
    } catch {
        return "ERROR: \(error)"
    }
}

/// This function creates the game and parses the testString to check turn and call the other various parser functions to complete the creation of the game depending on the input string.
///
/// - Parameter testString: input string that contains the current state configuration of the game and the moves that will be executed
/// - Returns: returns the game described in the string after the execution of the moves contained in the input string
/// - Throws: exception in case string in not long enough or in case the turn insede the string is wrong
func gameParser(testString: String) throws -> Game {
    
    guard testString.characters.count >= 67 else { throw Errors.InvalidStringLenght }
    
    guard testString[0] == "W" || testString[0] == "B" else { throw Errors.InvalidPlayerCharacter }
    
    var testGame = Game()
    do {
        testGame.pieces = testGame.createInitialPieces()
        let result = try boardParser(testString: testString,pieces: testGame.pieces)
        testGame.board = result.0
        let deadPieces = result.1
        for piece in deadPieces {
            testGame.pieces.filter({$0 === piece}).first?.currentVitality = 0
        }
        testGame.turn = testString[0]=="W" ? Color.white : Color.black
        try frozenParser(testString: testString, testGame: &testGame)
        try spellParser(testString: testString, testGame: &testGame)
        try moveParser(testString: testString, testGame: &testGame)
    } catch {
        throw error
    }
    return testGame
}

/// This function creates the board with pieces and their related vitalities. The array pieces contains all the pieces that will be added in the current game(along with their vitality) depending the configuration described in the string, the pieces added in the game will be removed from the array and the remaining ones will be set with vitality 0 cause they are dead pieces.
///
/// - Parameters:
///   - testString: input string that contains the current state configuration of the game and the moves that will be executed
///   - pieces: array that contains all the pieces in game
/// - Returns: the board containing pieces and their vitality and an array containing the pieces dead in the game
/// - Throws: throws exception in case the string doesn't contain board or vitality information checking its lenght
func boardParser(testString: String, pieces: [Piece]) throws -> (Board,[Piece]) {
    
    guard testString.characters.count >= 53 else { throw Errors.InvalidBoardVitalityStringLenght }
    
    //hardcoded special cells coordinates
    let specialCellsCoordinate = [Coordinate(0, 0),Coordinate(0, 3),Coordinate(5, 2),Coordinate(5, 5)]
    
    var board = Board(edge: 6, specialCells: specialCellsCoordinate)
    
    //These counter are used in the while-switch-case loop to read the part of the array that contains the configuration like if it was a matrix, reading it column per column
    var countRow = 1
    var countColumn = 1
    var pieceColor : Color
    
    //used to keep count of how much pieces we have already examined before, to know where to find the vitality related to the piece we are currently examining(since we have fixed structure in the test string)
    var pieceCounter = 0
    
    //array containing all the pieces created from the given string configuration
    var pieces: [Piece] = pieces
    var testVitality = 0
    
    while(countColumn<=6) {
        
        //find a way to not hardcode coordinate, move and attack values
        
        let testChar = testString[countRow]
        if (pieceCounter < 16 ){
            testVitality = Int(testString[37+pieceCounter])!
        }
        
        // real coordinate of the row for the matrix
        let realRow = ((countRow) - 1) / 6
        
        switch testChar {
            
        //case for Giant both White and Black
        case "G","g":
            pieceColor = testChar=="G" ? Color.white : Color.black
            
            if let piece = pieces.filter({$0.name == "Giant" && $0.color == pieceColor}).first,
                board.placePiece(piece: piece, at: Coordinate(realRow,countColumn - 1)) {
                board.getPiece(at: Coordinate(realRow,countColumn - 1))?.currentVitality = testVitality
                pieces = pieces.filter({$0 !== piece})
                pieceCounter = pieceCounter + 1
            }else{
                throw Errors.InvalidPieceOrCoordinate
            }
            
        //case for Dragon both White and Black
        case "D","d":
            pieceColor = testChar=="D" ? Color.white : Color.black
            
            if let piece = pieces.filter({$0.name == "Dragon" && $0.color == pieceColor}).first,
                board.placePiece(piece: piece, at: Coordinate(realRow,countColumn - 1)) {
                board.getPiece(at: Coordinate(realRow,countColumn - 1))?.currentVitality = testVitality
                pieces = pieces.filter({$0 !== piece})
                pieceCounter = pieceCounter + 1
            }else{
                throw Errors.InvalidPieceOrCoordinate
            }
            
        //case for Mage both White and Black
        case "M","m":
            pieceColor = testChar=="M" ? Color.white : Color.black

            if let piece = pieces.filter({$0.name == "Mage" && $0.color == pieceColor}).first,
                board.placePiece(piece: piece, at: Coordinate(realRow,countColumn - 1)) {
                board.getPiece(at: Coordinate(realRow,countColumn - 1))?.currentVitality = testVitality
                pieces = pieces.filter({$0 !== piece})
                pieceCounter = pieceCounter + 1
            }else{
                throw Errors.InvalidPieceOrCoordinate
            }
            
        //case for Archer both White and Black
        case "A","a":
            pieceColor = testChar=="A" ? Color.white : Color.black

            if let piece = pieces.filter({$0.name == "Archer" && $0.color == pieceColor}).first,
                board.placePiece(piece: piece, at: Coordinate(realRow,countColumn - 1)) {
                board.getPiece(at: Coordinate(realRow,countColumn - 1))?.currentVitality = testVitality
                pieces = pieces.filter({$0 !== piece})
                pieceCounter = pieceCounter + 1
            }else{
                throw Errors.InvalidPieceOrCoordinate
            }
            
        //case for Squire both White and Black
        case "S","s":
            pieceColor = testChar=="S" ? Color.white : Color.black

            if let piece = pieces.filter({$0.name == "Squire" && $0.color == pieceColor}).first,
                board.placePiece(piece: piece, at: Coordinate(realRow,countColumn - 1)) {
                board.getPiece(at: Coordinate(realRow,countColumn - 1))?.currentVitality = testVitality
                pieces = pieces.filter({$0 !== piece})
                pieceCounter = pieceCounter + 1
            }else{
                throw Errors.InvalidPieceOrCoordinate
            }
            
        //case for Knight both White and Black
        case "K","k":
            pieceColor = testChar=="K" ? Color.white : Color.black

            if let piece = pieces.filter({$0.name == "Knight" && $0.color == pieceColor}).first,
                board.placePiece(piece: piece, at: Coordinate(realRow,countColumn - 1)) {
                board.getPiece(at: Coordinate(realRow,countColumn - 1))?.currentVitality = testVitality
                pieces = pieces.filter({$0 !== piece})
                pieceCounter = pieceCounter + 1
            }else{
                throw Errors.InvalidPieceOrCoordinate
            }
            
        //case when we have 0 and we just have to create a cell without piece on it
        case "0":
            break
        default:
            throw Errors.InvalidBoardCharacter
        }
        
        countRow = countRow+6
        
        if (countRow>36) {
            countColumn = countColumn + 1
            countRow = countColumn
        }    }
    return (board,pieces)
}

/// Parses the input string checking the frozen pieces in the game and inserting that information inside the game
///
/// - Parameters:
///   - testString: input string that contains the current state configuration of the game and the moves that will be executed
///   - testGame: game in which the informations about the current frozen pieces state are being added
/// - Throws: throws exception in case the string is not complete
func frozenParser(testString: String, testGame: inout Game) throws {
    
    //start at 54 since we have fixed input string
    guard testString.characters.count >= 59 else { throw Errors.InvalidBoardFrozenPiecesStringLenght }
    
    var tempRow = 0
    var tempColumn = 0
    
    //contains the turn left for a frozen piece to be unfrozen
    var frozenPieceTurn = 0
    
    //used to check both white and black pieces
    var twoCounter = 0
    
    while (twoCounter < 6) {
        
        frozenPieceTurn = Int(testString[55 + twoCounter])!
        
        if (frozenPieceTurn > 0) {
            
            tempColumn = Int(testString[53 + twoCounter])!
            tempRow = Int(testString[54 + twoCounter])!
            
            testGame.board.matrix[tempRow-1,tempColumn-1].piece?.frozenTurnsLeft = frozenPieceTurn
            
        }
        twoCounter = twoCounter + 3
    }
}

/// Parses the input string checking which spell are currently active for each player.
///
/// - Parameters:
///   - testString: input string that contains the current state configuration of the game and the moves that will be executed
///   - testGame: game in which the informations about the current spells state are being added
/// - Throws: throws exception in case spells are missing in the input string
func spellParser(testString: String, testGame: inout Game) throws {
    
    guard testString.characters.count >= 67 else { throw Errors.InvalidBoardSpellStringLenght }
    
    let initialStringPosition = 59
    var loopCounter = 0
    
    //first phase of inizialization to false
    testGame.spellWhite[.freeze] = false
    testGame.spellWhite[.heal] = false
    testGame.spellWhite[.revive] = false
    testGame.spellWhite[.teleport] = false
    testGame.spellBlack[.freeze] = false
    testGame.spellBlack[.heal] = false
    testGame.spellBlack[.revive] = false
    testGame.spellBlack[.teleport] = false
    
    //change to true each available white spells
    repeat {
        switch testString[initialStringPosition + loopCounter] {
        case "F":
            testGame.spellWhite[.freeze] = true
        case "H":
            testGame.spellWhite[.heal] = true
        case "R":
            testGame.spellWhite[.revive] = true
        case "T":
            testGame.spellWhite[.teleport] = true
        case "0":
            break
        default:
            throw Errors.InvalidSpellCharacter
        }
        loopCounter = loopCounter + 1
    } while (loopCounter <= 3)
    //change to true each available black spells
    repeat {
        switch testString[initialStringPosition + loopCounter] {
        case "F":
            testGame.spellBlack[.freeze] = true
        case "H":
            testGame.spellBlack[.heal] = true
        case "R":
            testGame.spellBlack[.revive] = true
        case "T":
            testGame.spellBlack[.teleport] = true
        case "0":
            break
        default:
            throw Errors.InvalidSpellCharacter
        }
        loopCounter = loopCounter + 1
    } while (loopCounter <= 7)
}

/// Parses the input string computing the next move to execute in the game and calling the play function of the game.
///
/// - Parameters:
///   - testString: input string that contains the current state configuration of the game and the moves that will be executed
///   - testGame: game in which will be executed the moves contained inside the input string
/// - Throws: throws exception in case the substring containing the moves is not built correctly
func moveParser(testString: String, testGame: inout Game) throws {
    
    // check if there are no moves then return
    guard testString.characters.count > 67 else { return }
    
    //check there is at least one move and check the lenght of moves substring is multiple of five
    guard (testString.characters.count >= 72 || (testString.characters.count - 72)%5 == 0) else { throw Errors.InvalidMovesStringLenght }
    
    let startingStringPosition = 67
    let stringLenght = testString.characters.count
    var loopCounter = 0
    var currentAction: Action?
    var originCoordinate: Coordinate?
    var destinationCoordinate: Coordinate?
    var currentPiece: Piece? = nil
    
    repeat{
        //Computation of the needed coordinates both origin and destination
        originCoordinate = Coordinate(Int(testString[startingStringPosition + loopCounter + 2])! - 1,Int(testString[startingStringPosition + loopCounter + 1])! - 1)
        
        destinationCoordinate = Coordinate(Int(testString[startingStringPosition + loopCounter + 4])! - 1,Int(testString[startingStringPosition + loopCounter + 3])! - 1)
        
        switch testString[startingStringPosition + loopCounter] {
        case "M":
            currentAction = .move
        
            currentPiece = nil
        case "A":
            currentAction = .attack
            
            currentPiece = nil
        case "F":
            currentAction = .spell(.freeze)
            //nil since this action doesn't require a destination coordinate
            destinationCoordinate = nil
            
            currentPiece = nil
        case "H":
            currentAction = .spell(.heal)
            //nil since this action doesn't require a destination coordinate
            destinationCoordinate = nil
            
            currentPiece = nil
        case "R":
            currentAction = .spell(.revive)
            //nil since this action doesn't require a destination coordinate
            destinationCoordinate = nil
            //Revive spell requires a piece as a input parameter, here we set the piece to be used after in the play function
            if !(testGame.pieces.filter({$0.initialPosition == originCoordinate}).first == nil){
                currentPiece = testGame.pieces.filter({$0.initialPosition == originCoordinate}).first
            } else {
                throw Errors.InvalidSpellPieceCoordinate
            }
            
        case "T":
            currentAction = .spell(.teleport)
            
            currentPiece = nil
        default:
            throw Errors.InvalidMoveCharacter
        }
        let _ = testGame.play(startingCoordinate: originCoordinate, endingCoordinate: destinationCoordinate, action: currentAction!, piece: currentPiece)
        
        loopCounter = loopCounter + 5
        
    } while((loopCounter + startingStringPosition) < stringLenght)
}
