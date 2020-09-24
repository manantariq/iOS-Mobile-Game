//
//  Piece.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 02/11/16.
//
//

import Foundation


enum Color { case white, black }
enum MovementType { case walk, fly }
enum MovementDirection { case straight, diagonal, any }
enum AttackDirection { case straight, diagonal }

struct Move {
    var range: Int
    var direction: MovementDirection
    var movementType: MovementType
}

struct Attack {
    var range: Int
    var attackStrength: Int
    var direction: AttackDirection?
    
    init(range: Int, direction: AttackDirection? = nil, attackStrength: Int) {
        self.range = range
        self.direction = direction
        self.attackStrength = attackStrength
    }
}

class Piece {
    let id: Character
    let name: String
    let initialVitality: Int
    var currentVitality: Int
    let color: Color
    let initialPosition: Coordinate
    let movement: Move
    let attack: Attack
    let weight: Int
    var frozenTurnsLeft: Int
    let isMagic: Bool
    
    let icon: String
    let miniature_icon: String
    let frontend_name: String
    
    var isAlive: Bool { return self.currentVitality > 0 }
    var isFrozen: Bool { return self.frozenTurnsLeft > 0 }
    
    
    // Designated initializer
    init(id: Character, name: String, initialVitality: Int, currentVitality: Int, color: Color, initialPosition: Coordinate, movement: Move, attack: Attack, weight: Int, frozenTurnsLeft: Int, isMagic: Bool, icon: String, miniature_icon: String, frontend_name: String) {
        self.id = id
        self.name = name
        self.initialVitality = initialVitality
        self.currentVitality = currentVitality
        self.color = color
        self.initialPosition = initialPosition
        self.movement = movement
        self.attack = attack
        self.weight = weight
        self.frozenTurnsLeft = frozenTurnsLeft
        self.isMagic = isMagic
        self.icon = icon
        self.miniature_icon = miniature_icon
        self.frontend_name = frontend_name
    }
    
    /// Convenience initializer which sets the current vitality as the initial vitality and set the frozenTurnsLeft to 0
    convenience init(id: Character, name: String, initialVitality: Int, color: Color, initialPosition: Coordinate, movement: Move, attack: Attack, weight: Int, isMagic: Bool, icon: String, miniature_icon: String, frontend_name: String) {
        self.init(id: id, name: name, initialVitality: initialVitality, currentVitality: initialVitality, color: color, initialPosition: initialPosition, movement: movement, attack: attack, weight: weight, frozenTurnsLeft: 0, isMagic: isMagic, icon: icon, miniature_icon: miniature_icon, frontend_name: frontend_name)
    }
    
    
    /// Checks if the piece is able to move
    ///
    /// - returns: true if the piece is not frozen, false otherwise
    func hasMovementAbility() -> Bool {
        if (self.movement.range > 0) { return true }
        return false
    }
    
    
    /// Checks if the piece is able to attack
    ///
    /// - returns: true if the piece has an attack range greater than 0, false otherwise
    func hasAttackAbility() -> Bool {
        if (self.attack.range > 0) { return true }
        return false
    }
    
}
