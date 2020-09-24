//
//  Game.swift
//  MobileApp16
//
//  Created by Ilaria Carlini on 02/11/16.
//
//

import Foundation

enum Spell { case heal, teleport, freeze, revive }
enum Action { case move, attack, spell(Spell)}

struct Game {
    
    var board: Board
    var whitePlayer: Player
    var blackPlayer: Player
    var turn: Color // white or black
    var turnsCount: Int
    
    var pieces: [Piece] // list of all pieces
    
    var spellWhite: [Spell: Bool]
    var spellBlack: [Spell: Bool]
    
    var isGameEnded: Bool // can be setted at true only in checkGameState()
    var winner: Color? // can be .white, .black or nil. If 'isGameEnded' is true and at the same time winner is nil the result of the game is draw.
    
    var previousState: String?
    
    init() {
        self.board = Board(rows: 6, columns: 6)
        self.whitePlayer = Player(name: "", turn: .white, win: 0, draw: 0)
        self.blackPlayer = Player(name: "", turn: .black, win: 0, draw: 0)
        self.turn = .white // white starts
        self.turnsCount = 0
        self.pieces = []
        self.spellWhite = [:]
        self.spellBlack = [:]
        self.isGameEnded = false
    }

    /// Initialization of the board with a number of rows and columns, number
    /// and position of special Cells and initial pieces.
    mutating func startGame(player1: Player, player2: Player) {
        self.pieces = createInitialPieces()
        self.board = Board(rows: 6, columns: 6, specialCells: [Coordinate(0, 0), Coordinate(0, 3), Coordinate(5, 2), Coordinate(5, 5)], pieces: self.pieces)
        
        self.spellWhite = [ .heal : true, .freeze : true, .teleport : true, .revive : true ]
        self.spellBlack = [ .heal : true, .freeze : true, .teleport : true, .revive : true ]
        
        self.whitePlayer.name = player1.name
        self.blackPlayer.name = player2.name
    }
    
    
    /// Initial creation of all the pieces of the game
    func createInitialPieces() -> [Piece] {
        do {
            return try getPiecesFromJson()
        } catch {
            print(error)
            exit(0)
        }
    }
    
    /// Checks if the selected piece can moves.
    /// A piece can perform an action if the coordinates in input are valid:
    /// - there is a piece on the input passed
    /// - the piece is of the right color of the turn
    /// - the piece is not frozen
    func checkCoordinate(coordinate: Coordinate) -> Bool {
        var isSelectable = false
        
        if let piece = board.getPiece(at: coordinate) {
            guard self.turn == piece.color, !piece.isFrozen else { return isSelectable }
            isSelectable = true
        }
        return isSelectable
    }
    
    /// Spell: Heal - brings to its maximum the health of a selected piece
    ///
    /// - Parameter coordinate: the coordinate of the piece in which the spell has effect
    mutating func heal(coordinate: Coordinate) -> Bool {
        var isHealDone = false
        
        guard !board.isSpecialCell(cellCoordinate: coordinate) else { return isHealDone }
        if let piece = board.getPiece(at: coordinate) {
            guard self.turn == piece.color, piece.isAlive, piece.currentVitality < piece.initialVitality, !piece.isMagic else { return isHealDone }
            piece.currentVitality = piece.initialVitality
                    
            if self.turn == .white { self.spellWhite[.heal] = false }
            else { self.spellBlack[.heal] = false }
            isHealDone = true
        }
        return isHealDone
    }

    /// Spell: Teleport - moves a piece from a starting point to an ending one. Perform a combat action if the arrival coordinate is not free.
    ///
    /// - Parameters:
    ///   - startingCoordinate: coordinate of the piece that you want to teleport
    ///   - endingCoordinate:   arrival coordinate of the teleport
    mutating func teleport(startingCoordinate: Coordinate, endingCoordinate: Coordinate) -> (Bool, Int) {
        var isTeleportDone = false
        var combatTurnCount = 0
        
        // the starting cell must be occupied by a player’s piece
        if let playerPiece = board.getPiece(at: startingCoordinate) {
            
            // starting and ending cells are not specials and player's piece is not a mage
            guard !board.isSpecialCell(cellCoordinate: startingCoordinate), !board.isSpecialCell(cellCoordinate: endingCoordinate), !playerPiece.isMagic, playerPiece.color == turn else { return (isTeleportDone, combatTurnCount) }
                
            // there is a piece in the ending coordinate
            if let opponentPiece = board.getPiece(at: endingCoordinate) {
                guard playerPiece.color != opponentPiece.color, !opponentPiece.isMagic else { return (isTeleportDone, combatTurnCount) }
                combatTurnCount = combat(playerPiece: playerPiece, opponentPiece: opponentPiece)
                        
                if self.turn == .white { self.spellWhite[.teleport] = false }
                else { self.spellBlack[.teleport] = false }
                isTeleportDone = true
            } else {
                let _ = board.movePiece(startingCoordinate: startingCoordinate, endingCoordinate: endingCoordinate)
                    
                if turn == .white { self.spellWhite[.teleport] = false }
                else { self.spellBlack[.teleport] = false }
                isTeleportDone = true
            }
        }
        return (isTeleportDone, combatTurnCount)
    }
    
    /// Spell: Freeze -
    /// freezes for three turns a piece (a frozen piece cannot perform any action for its three following turns)
    ///
    /// - Parameter coordinate: the coordinate of the piece in which the spell has effect
    mutating func freeze(coordinate: Coordinate) -> Bool {
        var isFreezeDone = false
        guard !board.isSpecialCell(cellCoordinate: coordinate) else { return isFreezeDone }
        if let piece = board.getPiece(at: coordinate) {
            guard self.turn != piece.color && !piece.isMagic else { return isFreezeDone }
                    
            // array of frozen pieces of the opponent
            let opponentFrozens = self.pieces.filter {$0.color != turn && $0.isFrozen}
            var alreadyInList = false
            for frozenPiece in opponentFrozens {
                if piece === frozenPiece { alreadyInList = true }
            }
            guard alreadyInList == false else { return isFreezeDone }
            piece.frozenTurnsLeft = 3
            
            if self.turn == .white { self.spellWhite[.freeze] = false }
            else { self.spellBlack[.freeze] = false }
            isFreezeDone = true
        }
        return isFreezeDone
    }
    
    /// Spell: Revive -
    /// brings to its maximum the health of a selected piece and set to zero its frozen turn left.
    ///
    /// - Parameter pieceToRevive: the piece to bring back to life
    mutating func revive (pieceToRevive: Piece) -> (Bool, Int) {
        
        var isReviveDone = false
        var combatTurnCount = 0
        
        guard pieceToRevive.color == turn else { return (isReviveDone, combatTurnCount) }
        
        var canBeRevived = false
        for deadPiece in self.pieces.filter({ $0.color == turn && !$0.isAlive }) {
            if pieceToRevive === deadPiece { canBeRevived = true }
        }
        
        guard canBeRevived == true else { return (isReviveDone, combatTurnCount) }
    
        // If there is already a piece in the position in which the piece should be revived
        if let pieceInRevivePosition = board.getPiece(at: pieceToRevive.initialPosition) {
            // If the piece on position is an opposite's one
            if(pieceToRevive.color != pieceInRevivePosition.color) {
                pieceToRevive.currentVitality = pieceToRevive.initialVitality
                pieceToRevive.frozenTurnsLeft = 0
                    
                combatTurnCount = combat(playerPiece: pieceToRevive, opponentPiece: pieceInRevivePosition)
                        
                if self.turn == .white { self.spellWhite[.revive] = false }
                else { self.spellBlack[.revive] = false }
                isReviveDone = true
            }
            // If the piece on position is a player's piece
            else {
                // Retry if the piece has a twin on the twin's initial position
                if let twin = pieces.filter({ $0.color == pieceToRevive.color && $0.name == pieceToRevive.name && $0 !== pieceToRevive }).first {
                    // If exists a piece in the twin's position
                    if let pieceInRevivePosition = board.getPiece(at: twin.initialPosition) {
                        // and it's an opposite's one, combat
                        if pieceToRevive.color != pieceInRevivePosition.color {
                            pieceToRevive.currentVitality = pieceToRevive.initialVitality
                            pieceToRevive.frozenTurnsLeft = 0
                            
                            combatTurnCount = combat(playerPiece: pieceToRevive, opponentPiece: pieceInRevivePosition)

                            if self.turn == .white { self.spellWhite[.revive] = false }
                            else { self.spellBlack[.revive] = false }
                            isReviveDone = true
                        }
                    // If the twin's position is free
                    } else {
                        pieceToRevive.currentVitality = pieceToRevive.initialVitality
                        pieceToRevive.frozenTurnsLeft = 0
                        
                        let _ = board.placePiece(piece: pieceToRevive, at: twin.initialPosition)
                        
                        if self.turn == .white { self.spellWhite[.revive] = false }
                        else { self.spellBlack[.revive] = false }
                        isReviveDone = true
                    }
                    
                }
            }
        // the initial position of the piece is free
        } else {
            pieceToRevive.currentVitality = pieceToRevive.initialVitality
            pieceToRevive.frozenTurnsLeft = 0
            let _ = board.placePiece(piece: pieceToRevive, at: pieceToRevive.initialPosition)
                
            if self.turn == .white { self.spellWhite[.revive] = false }
            else { self.spellBlack[.revive] = false }
            isReviveDone = true
        }
        
        return (isReviveDone, combatTurnCount)
    }
    
    /// return coordinate where a dead piece can be revive
    ///
    /// - Parameter pieceToRevive: pieceToRevive
    /// - Returns: coordinate, Bool if is combat cell
    func getRevivePieceCoordinate(_ pieceToRevive: Piece) -> (Coordinate?,Bool) {
        
        guard let pieceInRevivePosition = board.getPiece(at: pieceToRevive.initialPosition) else {
            return (pieceToRevive.initialPosition,false) // the initial position of the piece is free
        }
        guard pieceToRevive.color == pieceInRevivePosition.color else {
            return (pieceToRevive.initialPosition,true) // the piece on position is an opposite's one, COMBAT
        }
        guard let twin = pieces.filter({ $0.color == pieceToRevive.color && $0.name == pieceToRevive.name && $0 !== pieceToRevive }).first else {
            return (nil,false)
        }
        // If exists a piece in the twin's position
        if let pieceInRevivePosition = board.getPiece(at: twin.initialPosition) {
            guard pieceToRevive.color != pieceInRevivePosition.color else {
                return (nil,false)
            }
            return(twin.initialPosition,true) // the piece on position is an opposite's one, COMBAT
        }
        // If the twin's position is free
        return (twin.initialPosition,false)
    }
    
    /// Move a piece from a starting to an ending point
    ///
    /// - Parameters:
    ///   - startingCoordinate: coordinate of player's piece
    ///   - endingCoordinate:   ending coordinate
    mutating func move(startingCoordinate: Coordinate, endingCoordinate: Coordinate) -> (Bool, Int) {
        var isMoveDone = false
        var combatTurnCount = 0
        
        let allowedMoves = board.allowedMoves(coordinate: startingCoordinate)
        guard allowedMoves.contains(endingCoordinate) else { return (isMoveDone, combatTurnCount) }
            
        // there is a piece at the ending coordinate
        if let playerPiece = board.getPiece(at: startingCoordinate), let opponentPiece = board.getPiece(at: endingCoordinate) {
            guard playerPiece.color != opponentPiece.color else { return (isMoveDone, combatTurnCount) }
            
            // num of turn spent in the combat
            combatTurnCount = combat(playerPiece: playerPiece, opponentPiece: opponentPiece)
            isMoveDone = true
        }
        // there is no piece at the ending coordinate
        else {
            let _ = board.movePiece(startingCoordinate: startingCoordinate, endingCoordinate: endingCoordinate)
            isMoveDone = true
        }
        return (isMoveDone, combatTurnCount)
    }
    
    /// Combat: this function can be called in multiple cases:
    /// 1. The combat as a result of a move
    /// 2. The combat as a result of a revive spell
    /// 3. The combat as a result of a teleport spell
    /// In all the cases the piece that is at the starting coordinate, if it will survive to the combat,
    /// will be moved to the ending coordinate.
    ///
    /// - Parameters:
    ///   - playerPiece:    a player's piece of the current turn
    ///   - opponentPiece:  an opponent's piace player
    mutating func combat(playerPiece: Piece, opponentPiece: Piece) -> Int {
        
        let playerPieceCoordinate = board.getPieceCoordinate(piece: playerPiece)
        let opponentPieceCoordinate = board.getPieceCoordinate(piece: opponentPiece)
        
        var combatTurnCount = 0
        
        // if the pieces are both not frozen
        if !playerPiece.isFrozen, !opponentPiece.isFrozen {
            while playerPiece.isAlive && opponentPiece.isAlive {
                playerPiece.currentVitality -= opponentPiece.attack.attackStrength
                opponentPiece.currentVitality -= playerPiece.attack.attackStrength
                
                combatTurnCount += 1
            }
        }
        // if player's piece is not frozen, opponent's piece is frozen
        else if !playerPiece.isFrozen, opponentPiece.isFrozen {
            opponentPiece.currentVitality = 0
        }
        // if player's piece is frozen, opponent's piece is not frozen
        else if playerPiece.isFrozen, !opponentPiece.isFrozen {
            playerPiece.currentVitality = 0
        }
        // if both pieces are frozen
        else {
            playerPiece.currentVitality = 0
            opponentPiece.currentVitality = 0
        }
        
        if !opponentPiece.isAlive {
            let _ = board.removePiece(from: opponentPieceCoordinate!)
        }
        
        if !playerPiece.isAlive {
            if playerPieceCoordinate != nil {
                let _ = board.removePiece(from: playerPieceCoordinate!)
            }
        } else {
            // the player piece is currently on the board
            if playerPieceCoordinate != nil {
                let _ = board.movePiece(startingCoordinate: playerPieceCoordinate!, endingCoordinate: opponentPieceCoordinate!)
            }
            // the player piece is the one that has to be revitalized
            else {
                let _ = board.placePiece(piece: playerPiece, at: opponentPieceCoordinate!)
            }
        }
        return combatTurnCount
    }
    
    /// Performs an attack between two pieces. The life of the attacked piece is decremented by the strength of the attacking piece.
    ///
    /// - Parameters:
    ///   - startingCoordinate: the coordinate in which there is the piece that perform the attack
    ///   - endingCoordinate:   the coordinate of the attacked piece
    mutating func attack(startingCoordinate: Coordinate, endingCoordinate: Coordinate) -> Bool {
        var isAttackDone = false
        
        let allowedAttack = board.allowedAttacks(coordinate: startingCoordinate)
        guard allowedAttack.contains(endingCoordinate) else { return isAttackDone }
        
        if let playerPiece = board.getPiece(at: startingCoordinate), let opponentPiece = board.getPiece(at: endingCoordinate) {
            opponentPiece.currentVitality -= playerPiece.attack.attackStrength
            isAttackDone = true
            guard !opponentPiece.isAlive else { return isAttackDone }
            let _ = board.removePiece(from: endingCoordinate)
        }
        return isAttackDone
    }
    
    /// Shows the possible coordinates in which a piece can moves or attacks
    ///
    /// - Parameter coordinate: the coordinate in which is the piece that you want to use
    func highlightPossibleActions(coordinate: Coordinate) -> (allowedMoves: [Coordinate], allowedAttacks: [Coordinate]) {
        if let piece = board.getPiece(at: coordinate) {
            if piece.color == turn {
                return (board.allowedMoves(coordinate: coordinate), board.allowedAttacks(coordinate: coordinate))
            }
        }
        return ([], [])
    }
    
    /// Performs the action: movement, attack or spell
    ///
    /// - Parameters:
    ///   - startingCoordinate: coordinate of the player's piece
    ///   - endingCoordinate:   coordinate of the enemy's piece
    ///   - action:             move | attack | spell
    ///   - piece:              allows to invoke the revive spell (optional)
    mutating func play(startingCoordinate: Coordinate?, endingCoordinate: Coordinate?, action: Action, piece: Piece? = nil) -> (Bool, Int) {
        
        var isPlayPerformed = false
        var combatTurnCount = 0
        
        guard !isGameEnded else {
            print("Tried to play when game already ended")
            return (isPlayPerformed, combatTurnCount)
        }
        
        // Saving the current state of the game for undo mechanism
        let initialState = self.stateDescription
        
        switch action {
            
        // perform movement
        case .move:
            if let startingCoordinate = startingCoordinate {
                if let playerPiece = board.getPiece(at: startingCoordinate) {
                    // if you're moving a piece which is of your color and is not frozen
                    guard playerPiece.color == turn, !playerPiece.isFrozen else { break }
                    if let endingCoordinate = endingCoordinate {
                        // if the movement has been correctly performed
                        (isPlayPerformed, combatTurnCount) = move(startingCoordinate: startingCoordinate, endingCoordinate: endingCoordinate)
                    }
                }
            }
            
        // perform attack
        case .attack:
            if let startingCoordinate = startingCoordinate, let endingCoordinate = endingCoordinate {
                // if both the playerPiece and the opponentPiece exist
                if let playerPiece = board.getPiece(at: startingCoordinate), let _ = board.getPiece(at: endingCoordinate) {
                    // the piece must be able to attack (range > 0 ) and has to be not frozen
                    guard playerPiece.attack.range > 0, playerPiece.color == turn, !playerPiece.isFrozen  else { break }
                    let allowedAttack = board.allowedAttacks(coordinate: startingCoordinate)
                    if allowedAttack.contains(endingCoordinate) {
                        if let opponentPiece = board.getPiece(at: endingCoordinate) {
                            guard opponentPiece.color != turn else { break }
                            isPlayPerformed = attack(startingCoordinate: startingCoordinate, endingCoordinate: endingCoordinate)
                        }
                    }
                }
            }
            
        // perform spell
        case .spell(let spellDescription):
            
            guard isMageAlive(color: turn) else { break }
            
            switch spellDescription {
            case .heal:
                if self.turn == .white {
                    guard self.spellWhite[.heal] == true else { break }
                    if let startingCoordinate = startingCoordinate {
                        isPlayPerformed = heal(coordinate: startingCoordinate)
                    }
                } else {
                    guard self.spellBlack[.heal] == true else { break }
                    if let startingCoordinate = startingCoordinate {
                        isPlayPerformed = heal(coordinate: startingCoordinate)
                    }
                }
                
            case .teleport:
                if self.turn == .white {
                    guard self.spellWhite[.teleport] == true else { break }
                    if let startingCoordinate = startingCoordinate, let endingCoordinate = endingCoordinate {
                        (isPlayPerformed, combatTurnCount) = teleport(startingCoordinate: startingCoordinate, endingCoordinate: endingCoordinate)
                    }
                } else {
                    guard self.spellBlack[.teleport] == true  else { break }
                    if let startingCoordinate = startingCoordinate, let endingCoordinate = endingCoordinate {
                        (isPlayPerformed, combatTurnCount) = teleport(startingCoordinate: startingCoordinate, endingCoordinate: endingCoordinate)
                    }
                }
                
            case .freeze:
                if self.turn == .white {
                    guard self.spellWhite[.freeze] == true else { break }
                    if let startingCoordinate = startingCoordinate {
                        isPlayPerformed = freeze(coordinate: startingCoordinate)
                    }
                } else {
                    guard self.spellBlack[.freeze] == true else { break }
                    if let startingCoordinate = startingCoordinate {
                        isPlayPerformed = freeze(coordinate: startingCoordinate)
                    }
                }
                
            case .revive:
                if self.turn == .white {
                    guard self.spellWhite[.revive] == true else { break }
                    if let pieceToRevive = piece {
                        (isPlayPerformed, combatTurnCount) = revive(pieceToRevive: pieceToRevive)
                    }
                } else {
                    guard self.spellBlack[.revive] == true else { break }
                    if let pieceToRevive = piece {
                        (isPlayPerformed, combatTurnCount) = revive(pieceToRevive: pieceToRevive)
                    }
                }
            }
        }
        
        if isPlayPerformed {
            self.turnsCount += 1
            self.previousState = initialState
            checkGameState()
        } else {
            print("Game: Invalid Move")
        }
        
        return (isPlayPerformed, combatTurnCount)
    }
    
    func piecesOnSpecialCell(color: Color) -> Int {
        // SPECIAL CELLS
        // check if the special cells are occupied for 3/4 of pieces of the same color
        let specialCells: [Cell] = board.specialCells
        var pieceOnSpecialCell = 0
        for cell in specialCells {
            // if there is a piece on the cell
            if let piece = cell.piece {
                // and is of the same color of the turn
                if (color == piece.color) { pieceOnSpecialCell += 1 }
            }
        }
        return pieceOnSpecialCell
    }
    
    /// Checks the state game: check all the possibility of winning the game
    /// - the occupation of the special cells
    /// - the possibility of the opponent to move pieces during its following turn
    /// - the manage of the frozen turns
    mutating func checkGameState() {
        
        if piecesOnSpecialCell(color: self.turn) >= 3 {
            isGameEnded = true
            winner = turn
        }
    
        // Since the turn is almost finished, I manage the frozen turn left of the pieces.
        unfreezePiece()
        
        // if all the player's pieces are frozen or dead
        if self.pieces.filter ({ $0.color == turn && (!$0.isAlive || $0.isFrozen) }).count == self.pieces.filter ({ $0.color == turn }).count {
            
            if self.pieces.filter ({ $0.color != turn && (!$0.isAlive || $0.isFrozen) }).count == self.pieces.filter ({ $0.color != turn }).count {
                
                // also the opponent's pieces are all frozen or dead -> draw
                isGameEnded = true
                winner = nil // draw
            } else {
                isGameEnded = true
                if turn == .white { winner = .black }
                else { winner = .white }
            }
        }
        // there is at least one piece alive and not frozen, check if the opponent has at least one piece alive and not frozen
        else {
            if self.pieces.filter ({ $0.color != turn && (!$0.isAlive || $0.isFrozen) }).count == self.pieces.filter ({ $0.color != turn }).count {
                isGameEnded = true
                winner = turn
            }
        }
        
        if(isGameEnded) { endGame() }
        else { changeTurn() }
    }
    
    
    /// Manages the presence of frozen pieces in the game
    func unfreezePiece() {
        for frozenPiece in self.pieces.filter ({ $0.color == turn && $0.isFrozen }) {
            frozenPiece.frozenTurnsLeft -= 1
        }
    }
    
    /// Changes the Game attribute turn of the play
    mutating func changeTurn() {
        if(self.turn == .black) { self.turn = .white }
        else { self.turn = .black }
    }
    
    /// func that end the current game
    func endGame() {
        if isGameEnded == true {
            switch(winner) {
                case .white?:
                    whitePlayer.win += 1
                case .black?:
                    blackPlayer.win += 1
                case nil:
                    whitePlayer.draw += 1
                    blackPlayer.draw += 1
            }
        }
    }
    
    func isMageAlive(color: Color) -> Bool {
        let mages = pieces.filter({ piece in piece.isMagic })
        
        for mage in mages {
            if mage.color == color && mage.isAlive && !mage.isFrozen {
                return true
            }
        }
        return false
    }
    
    func getSpells(forColor: Color) -> [Spell: Bool] {
        switch forColor {
        case .black:
            return spellBlack
        case .white:
            return spellWhite
        }
    }
        
    /// Returns the coordinates of pieces to which a spell can be casted
    func getAllowedSpellCoordinate(spell: Spell) -> [Coordinate] {
        
        var cells: Set<Coordinate> = []
        var recipientPieces: Array<Piece>
        
        switch spell {
        case .heal:
            recipientPieces = pieces.filter { $0.color == turn && $0.isAlive && !$0.isMagic && $0.currentVitality < $0.initialVitality }
        case .freeze:
            recipientPieces = pieces.filter { $0.color != turn && $0.isAlive && !$0.isMagic }
        case .teleport:
            recipientPieces = pieces.filter { $0.color == turn && $0.isAlive && !$0.isMagic }
        case .revive:
            recipientPieces = []
            let deadPieces = pieces.filter { $0.color == turn && !$0.isAlive && !$0.isMagic }
            for pieceToRevive in deadPieces {
                if let pieceInRevivePosition = board.getPiece(at: pieceToRevive.initialPosition) {
                    if (pieceToRevive.color != pieceInRevivePosition.color) {
                        recipientPieces.append(pieceToRevive)
                    } else {
                        if let twin = pieces.filter({ $0.color == pieceToRevive.color && $0.name == pieceToRevive.name && $0 !== pieceToRevive }).first {
                            if let pieceInRevivePosition = board.getPiece(at: twin.initialPosition) {
                                if pieceToRevive.color != pieceInRevivePosition.color {
                                    recipientPieces.append(pieceToRevive)
                                }
                            } else {
                                recipientPieces.append(pieceToRevive)
                            }
                        }
                    }
                } else {
                    recipientPieces.append(pieceToRevive)
                }
            }
            
            return recipientPieces.map({ return $0.initialPosition })
        }
        
        // Composing the set of coordinates while ignoring special cells
        cells = Set(recipientPieces.map({ return board.getPieceCoordinate(piece: $0)! })).subtracting(board.specialCellsCoordinates)
        
        return Array(cells)
    }
    
    mutating func undoMove() {
        guard let previousState = self.previousState else { return }
        
        // RESET GAME ENDED'S PROPERTIES
        self.isGameEnded = false
        self.winner = nil
        
        // TURN
        self.turn = previousState[0] == "W" ? .white : .black
        
        // PIECES
        let boardStateLength = previousState.characters.count - 9   // 1 turn and 8 spells
        self.board.recoverState(state: previousState[1,1+boardStateLength], pieces: self.pieces)
        
        // REMAINING SPELLS
        let spellsBaseIndex = previousState.characters.count - 8    // 8 spells
        
        for spellIndex in 0...7 {
            let spellChar = previousState[spellsBaseIndex + spellIndex]
            
            let spell: Spell?
            switch spellChar {
            case "F": spell = .freeze
            case "H": spell = .heal
            case "R": spell = .revive
            case "T": spell = .teleport
            default: spell = nil
            }
            
            if spell != nil {
                if spellIndex < 4 {
                    self.spellWhite[spell!] = true
                } else {
                    self.spellBlack[spell!] = true
                }
            }
        }
        
        // Decrement number of turns
        self.turnsCount -= 1
        
        // Clearing previous state variable
        self.previousState = nil
    }
        
}


extension Game: CustomStringConvertible {
    /// Creates a String description of the elements of the Game:
    ///     -creation of a string that will contain all the information about the current game
    ///     -gather current turn color and append it to the string
    ///     -call descriptionBoard function of the board object to compute the current configuration
    ///         of the board and append the returned string to the final string
    ///     -gathering information about the current state of the spell in the game, creating a representing
    ///         string of that state and append it to the final String
    ///     -return the final string
    var description: String {
        // Final string creation
        var gameDescriptionString = ""
        
        // Turn append
        if (turn == .white) {
            gameDescriptionString.append("W")
        } else {
            gameDescriptionString.append("B")
        }
        
        // Board description creation and append
        gameDescriptionString.append(board.fullDescription)
        // Spells String creation and append
        gameDescriptionString.append(spellsString)
        
        return gameDescriptionString
    }
    
    var stateDescription: String {
        var gameStateDescription = ""
        
        // Turn append
        if (turn == .white) {
            gameStateDescription.append("W")
        } else {
            gameStateDescription.append("B")
        }
        
        // Board description creation and append
        gameStateDescription.append(board.stateDescription)
        // Spells String creation and append
        gameStateDescription.append(spellsString)
        
        return gameStateDescription
    }
    
    var spellsString: String {
        var spellsString = ""
        
        // White spell string append
        if (spellWhite[.freeze] == true) {
            spellsString.append("F")
        } else { spellsString.append("0") }
        if (spellWhite[.heal] == true) {
            spellsString.append("H")
        } else { spellsString.append("0") }
        if (spellWhite[.revive] == true) {
            spellsString.append("R")
        } else { spellsString.append("0") }
        if (spellWhite[.teleport] == true) {
            spellsString.append("T")
        } else { spellsString.append("0") }
        
        // Black spell string append
        if (spellBlack[.freeze] == true) {
            spellsString.append("F")
        } else { spellsString.append("0") }
        if (spellBlack[.heal] == true) {
            spellsString.append("H")
        } else { spellsString.append("0") }
        if (spellBlack[.revive] == true) {
            spellsString.append("R")
        } else { spellsString.append("0") }
        if (spellBlack[.teleport] == true) {
            spellsString.append("T")
        } else { spellsString.append("0") }
        
        return spellsString
    }
}
