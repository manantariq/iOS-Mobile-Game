//
//  JsonParser.swift
//  MobileApp16
//
//  Created by manan tariq on 23/11/16.
//
//

import Foundation

enum Serialization : Error {
    case readingFile(String)
    case missing(String)
    case syntaxError(String)
}

/// Get Json data from Pieces.json file
/// - returns: NSData
func getJsonData() throws -> NSData {
    
    do {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "Pieces", ofType: "json")
        let data : NSData = try NSData(contentsOfFile: path!)
        return data
    } catch {
        throw Serialization.readingFile("Error in getJsonData ")
    }
}

/// Parse json data and creates pieces for black and white player
/// - returns: [Piece]
func getPiecesFromJson() throws -> [Piece] {
    
    var pieces : [Piece] = []
    var json : Any
    var pieceId: UnicodeScalar = "A"
    
    do {
        json = try JSONSerialization.jsonObject(with: getJsonData() as Data, options: [])
    } catch {
        throw error
    }
    
    guard let dictionary = json as? [String: Any] else {
        throw Serialization.readingFile("Error in getPiecesFromJson \n")
    }
    
    guard let black = dictionary["Black"] as? [String: Any] else {
        throw Serialization.missing("Missing Black Player Pieces \n")
    }
    guard let white = dictionary["White"] as? [String: Any] else {
        throw Serialization.missing("Missing White Player Pieces \n")
    }
    
    do {
        // Get Black Player Pieces from json
        for (key, value) in black {
            pieces.insert(contentsOf: try createPieces(name: key, values: (value as? [String: Any])!, color: Color.black, id: &pieceId), at: pieces.endIndex)
        }
        
        // Get White Player Pieces from json
        for (key, value) in white {
            pieces.insert(contentsOf: try createPieces(name: key, values: (value as? [String: Any])!, color: Color.white, id: &pieceId), at: pieces.endIndex)
        }
    } catch {
        throw error
    }
    
    guard pieces.filter({$0.color == .white}).count == pieces.filter({$0.color == .black}).count else {
        throw Serialization.missing("The number of blacks and whites pieces is not equal. Please control Pieces.json file ")
    }
    
    return pieces
}

/// Create Pieces
///
/// - Parameters:
///   - name: Piece name
///   - values: Piece default value
///   - color: player white or player black
///
/// - returns: an array of pieces
func createPieces(name: String, values: [String: Any], color: Color, id: inout UnicodeScalar) throws -> [Piece] {
    
    var pieces: [Piece] = []
    
    guard let InitialVitality = values["InitialVitality"] as? Int else { throw Serialization.missing("Missing \(color) \(name) InitialVitality ") }
    
    guard let InitialPosition = values["InitialPosition"] as? [[Int]] else { throw Serialization.missing("Missing \(color) \(name) InitialPosition ") }
    
    guard let Moves = values["Move"] as? [String: Any] else { throw Serialization.missing("Missing \(color) \(name) Move ") }
    guard let MoveRange = Moves["Range"] as? Int else { throw Serialization.missing("Missing \(color) \(name) Move Range ") }
    guard let MoveDirections = Moves["Directions"] as? String else { throw Serialization.missing("Missing \(color) \(name) Move Directions ") }
    guard let MoveTypes = Moves["Type"] as? String else { throw Serialization.missing("Missing \(color) \(name) Move Type ") }
    
    guard let Attacks = values["Attack"] as? [String: Any] else { throw Serialization.missing("Missing \(color) \(name) Attack ") }
    guard let AttackRange = Attacks["Range"] as? Int else { throw Serialization.missing("Missing \(color) \(name) Attack Range ") }
    guard let AttackStrength = Attacks["Strength"] as? Int else { throw Serialization.missing("Missing \(color) \(name) Attack Strength ") }
    guard let AttackDirections = Attacks["Directions"] as? String else { throw Serialization.missing("Missing \(color) \(name) Attack Directions ") }
    
    guard let weight = values["weight"] as? Int else { throw Serialization.missing("Missing \(color) \(name) weight ") }
    guard let isMagic = values["isMagic"] as? Bool else { throw Serialization.missing("Missing \(color) \(name) isMagic ") }
    
    guard let icon = values["icon"] as? [String] else { throw Serialization.missing("Missing \(color) \(name) icon ") }
    guard let miniature_icon = values["miniature-icon"] as? [String] else { throw Serialization.missing("Missing \(color) \(name) miniature-icon ") }
    guard let frontend_name = values["frontend_name"] as? [String] else { throw Serialization.missing("Missing \(color) \(name) frontend_name ") }
    guard (MoveDirections == "H-V" || MoveDirections == "Any"),
        (MoveTypes == "Walk" || MoveTypes == "Flight"),
        (AttackDirections == "H-V" || AttackDirections == "Diagonal" ||
            AttackDirections == "ND") else {
                throw Serialization.syntaxError("Wrong syntax for Movement or Attack ")
    }
    
    
    let MoveDirection = MoveDirections == "H-V" ? MovementDirection.straight : MovementDirection.any
    
    let MoveType = MoveTypes == "Walk" ? MovementType.walk : MovementType.fly
    
    let AttackDir = AttackDirections == "H-V" ? AttackDirection.straight : (AttackDirections == "Diagonal" ? AttackDirection.diagonal : nil)
    
    var count = 0
    // if there are duplicate pieces with different coordinate
    for pos in InitialPosition {
        pieces.append(Piece(id: Character(id), name: name, initialVitality: InitialVitality, color: color, initialPosition: Coordinate(pos[0],pos[1]), movement: Move(range: MoveRange, direction: MoveDirection,movementType: MoveType), attack: Attack(range: AttackRange, direction: AttackDir, attackStrength: AttackStrength), weight: weight, isMagic: isMagic, icon: icon[count], miniature_icon: miniature_icon[count], frontend_name: frontend_name[count]))
        
        id = UnicodeScalar(id.value + 1)!
        count += 1
    }
    
    return pieces
}
