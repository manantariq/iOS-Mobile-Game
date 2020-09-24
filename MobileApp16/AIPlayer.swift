//
//  AIPlayer.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 12/12/16.
//
//

import Foundation

protocol AIPlayer {
    var AIColor: Color { get }
    
    mutating func nextMove(currentGame: Game) -> String
}

struct AIMiniMaxPlayer: AIPlayer {
    let AIColor: Color
    let maxDepth: Int8
    
    init(color: Color, maxDepth: Int8) {
        self.AIColor = color
        self.maxDepth = maxDepth
    }
    
    func nextMove(currentGame: Game) -> String {
        print("AIMiniMaxPlayer Started")
        
        let chosenDepth = valuateComplexity(game: currentGame)
        print("\tDepth: " + String(chosenDepth))
        
        let (score, moveString) = minimax(game: currentGame, depth: chosenDepth, alpha: Int.min, beta: Int.max, initialDepth: chosenDepth)
        print("\tScore: \(score)")
        print("\tMove: \(moveString.isEmpty ? "Empty" : moveString)")
        print()
        
        return moveString
    }
    
    private func minimax(game: Game, depth: Int8, alpha: Int, beta: Int, initialDepth: Int8) -> (Int, String) {
        var score: Int = (game.turn == AIColor) ? Int.min : Int.max
        var alpha = alpha, beta = beta
        var prune = false
        var localGame = game
        var moveString = ""
        var currentMove = ""
        var firstLevel: Bool = (depth == initialDepth)
        
        // Leaf Valuation
        if depth == 0 || localGame.isGameEnded {
            score = valuateGame(game: localGame)
            return (score, moveString)
        }

        func computeScore() {
            let (newScore, _) = minimax(game: localGame, depth: depth-1, alpha: alpha, beta: beta, initialDepth: initialDepth)
            localGame.undoMove()
            
            if game.turn == AIColor {    // Maximizing Player
                let oldScore = score
                score = max(score, newScore)
                alpha = max(alpha, score)
                // Updating Move
                if firstLevel && (newScore > oldScore || moveString.isEmpty) {
                    moveString = currentMove
                }
                // Beta Pruning
                if beta <= alpha {
                    prune = true
                }
            } else {                // Minimizing Player
                score = min(score, newScore)
                beta = min(beta, score)
                // Alpha Pruning
                if beta <= alpha {
                    prune = true
                }
            }
        }
        
        // For each alive piece of the AI, explore all the possible moves
        let turnAlivePieces = localGame.pieces.filter({ p in p.color == localGame.turn && p.isAlive && !p.isFrozen })
        for piece in turnAlivePieces {
            guard let pieceC = localGame.board.getPieceCoordinate(piece: piece) else { continue }
            // Moves
            let allowedMoves = localGame.board.allowedMoves(coordinate: pieceC)
            for move in allowedMoves {
                if firstLevel {
                    currentMove = "M\(pieceC.col+1)\(pieceC.row+1)\(move.col+1)\(move.row+1)"
                }
                // Playing
                guard localGame.play(startingCoordinate: pieceC, endingCoordinate: move, action: .move).0 else { continue }
                computeScore()
                if prune { return (score, moveString) } // Alpha-Beta Pruning
            }
            // Attacks
            let allowedAttacks = localGame.board.allowedAttacks(coordinate: pieceC)
            for attack in allowedAttacks {
                if firstLevel {
                    currentMove = "A\(pieceC.col+1)\(pieceC.row+1)\(attack.col+1)\(attack.row+1)"
                }
                // Playing
                guard localGame.play(startingCoordinate: pieceC, endingCoordinate: attack, action: .attack).0 else { continue }
                computeScore()
                if prune { return (score, moveString) } // Alpha-Beta Pruning
            }
        }
        
        /*** Spells ***/
        guard localGame.isMageAlive(color: localGame.turn) else { return (score, moveString) }
        
        // Freeze
        if localGame.getSpells(forColor: localGame.turn)[.freeze]! {
            let freezeCoordinates = localGame.getAllowedSpellCoordinate(spell: .freeze)
            for opponentPieceC in freezeCoordinates {
                if firstLevel {
                    currentMove = "F\(opponentPieceC.col+1)\(opponentPieceC.row+1)00"
                }
                // Playing
                guard localGame.play(startingCoordinate: opponentPieceC, endingCoordinate: nil, action: .spell(.freeze)).0 else { continue }
                computeScore()
                if prune { return (score, moveString) } // Alpha-Beta Pruning
            }
        }
        // Heal
        if localGame.getSpells(forColor: localGame.turn)[.heal]! {
            let healCoordinates = localGame.getAllowedSpellCoordinate(spell: .heal)
            for injuredPieceC in healCoordinates {
                if firstLevel {
                    currentMove = "H\(injuredPieceC.col+1)\(injuredPieceC.row+1)00"
                }
                // Playing
                guard localGame.play(startingCoordinate: injuredPieceC, endingCoordinate: nil, action: .spell(.heal)).0 else { continue }
                computeScore()
                if prune { return (score, moveString) } // Alpha-Beta Pruning
            }
        }
        // Revive
        if localGame.getSpells(forColor: localGame.turn)[.revive]! {
            let reviveCoordinates = localGame.getAllowedSpellCoordinate(spell: .revive)
            for deadPieceInitialC in reviveCoordinates {
                let deadPiece = localGame.pieces.first(where: {$0.initialPosition == deadPieceInitialC})
                guard deadPiece != nil else { continue }
                if firstLevel {
                    currentMove = "R\(deadPiece!.initialPosition.col+1)\(deadPiece!.initialPosition.row+1)00"
                }
                // Playing
                guard localGame.play(startingCoordinate: nil, endingCoordinate: nil, action: .spell(.revive), piece: deadPiece).0 else { continue }
                computeScore()
                if prune { return (score, moveString) } // Alpha-Beta Pruning
            }
        }
        // Teleport
        if localGame.getSpells(forColor: localGame.turn)[.teleport]! {
            // Probability of doing the teleport
            //guard Double(arc4random_uniform(2)) < 1 else { return score }
            
            let freeCellsC = localGame.board.freeCellsCoordinates
            let opponentPiecesC = Set(localGame.pieces
                .filter({ $0.color != localGame.turn && $0.isAlive && !$0.isMagic })
                .map({ return localGame.board.getPieceCoordinate(piece: $0)!}))
            
            let destCellsC = freeCellsC.union(opponentPiecesC).subtracting(localGame.board.specialCellsCoordinates)
            
            let teleportingPiecesC = localGame.getAllowedSpellCoordinate(spell: .teleport)
            for pieceC in teleportingPiecesC {
                for destCellC in destCellsC {
                    if firstLevel {
                        currentMove = "T\(pieceC.col+1)\(pieceC.row+1)\(destCellC.col+1)\(destCellC.row+1)"
                    }
                    // Playing
                    guard localGame.play(startingCoordinate: pieceC, endingCoordinate: destCellC, action: .spell(.teleport)).0 else { continue }
                    computeScore()
                    if prune { return (score, moveString) } // Alpha-Beta Pruning
                }
            }
        }

        return (score, moveString)
    }
    
    private func valuateComplexity(game: Game) -> Int8 {
        var AIComplexity: Int8 = 2
        let pieceCounter = game.pieces.filter({ p in p.isAlive }).count
        let teleportWhite = game.spellWhite[.teleport]! && game.isMageAlive(color: .white)
        let teleportBlack = game.spellBlack[.teleport]! && game.isMageAlive(color: .black)
        
        if (pieceCounter <= 8), (!teleportWhite && !teleportBlack) {
            AIComplexity += 1
        }
        
        return min(AIComplexity, maxDepth)
    }
    
    private func valuateGame(game: Game) -> Int {
        var score: Int = 0
        
        guard (!game.isGameEnded) else {
            if let winner = game.winner {
                if winner == AIColor { return Int.max }
                else { return Int.min }
            } else {
                return Int.max / 2  // Draw
            }
        }
        
        var reachableSpCells = Set<Coordinate>()
        var canAlreadyMoveOntoFrozenAI = false
        var canAlreadyMoveOntoFrozenPly = false
        let arrayAliveAIPieces: Array<Piece> = game.pieces.filter({ p in p.isAlive && p.color == AIColor })
        let arrayAliveOpponentPieces: Array<Piece> = game.pieces.filter({ p in p.isAlive && p.color != AIColor })
        let specialCellsCoordinates = game.board.specialCellsCoordinates
        
        
        // First metric. Balance between the number of pieces of the two factions
        let countAIPieces = arrayAliveAIPieces.count
        let countOpponentPieces = arrayAliveOpponentPieces.count
        score += (countAIPieces - countOpponentPieces) * 8
        
        // Cycling through the opponent pieces
        for opponentPiece in arrayAliveOpponentPieces {
            //score -= ((opponentPiece.currentVitality / opponentPiece.initialVitality) + (opponentPiece.attack.attackStrength / opponentPiece.currentVitality)) * opponentPiece.weight
            
            if (opponentPiece.isFrozen) {
                score += (opponentPiece.currentVitality + opponentPiece.attack.attackStrength + opponentPiece.weight) / 2
            } else {
                score -= (opponentPiece.currentVitality + opponentPiece.attack.attackStrength + opponentPiece.initialVitality + opponentPiece.weight * 2)
                
                // We must be able to retrieve the piece's coordinates
                guard let pieceCoord = game.board.getPieceCoordinate(piece: opponentPiece) else { continue }
                
                let allowedMoves = Set(game.board.allowedMoves(coordinate: pieceCoord))
                
                // Check if an opponent can move onto our frozen piece
                if !canAlreadyMoveOntoFrozenAI {
                    for move in allowedMoves {
                        if let piece = game.board.getPiece(at: move) {
                            if piece.color == AIColor && piece.isFrozen {
                                score -= 5
                                canAlreadyMoveOntoFrozenAI = true
                                break
                            }
                        }
                    }
                }
                
                // Subtract points if the opponent archer can attack some AI piece
                if (opponentPiece.name == "Archer") {
                    let allowedAttacks = Set(game.board.allowedAttacks(coordinate: pieceCoord))
                    if allowedAttacks.count > 0 {
                        score -= 7
                    }
                }
                
                // Subtract points if the opponent dragon can attack some AI piece
                if (opponentPiece.name == "Dragon") {
                    let allowedAttacks = Set(game.board.allowedAttacks(coordinate: pieceCoord))
                    if allowedAttacks.count > 0 {
                        score -= 8
                    }
                }
            }
            
        }   // End cycling through the opponent pieces
        
        // Clycling through AI pieces
        for AIPiece in arrayAliveAIPieces {
            //score += ((AIPiece.currentVitality / AIPiece.initialVitality) + (AIPiece.attack.attackStrength / AIPiece.currentVitality)) * AIPiece.weight
            //dare maggiore peso alla vita corrente del mago tirando fuori dalla parentesi la variabile e moltiplicandola invece che per 2 per 3
            
            if (AIPiece.isFrozen) {
                score -= (AIPiece.currentVitality + AIPiece.attack.attackStrength + AIPiece.weight) / 2
            } else {
                score += (AIPiece.currentVitality + AIPiece.attack.attackStrength + AIPiece.initialVitality + AIPiece.weight * 2)
                
                // We must be able to retrieve the piece's coordinates
                guard let pieceCoord = game.board.getPieceCoordinate(piece: AIPiece) else { continue }
                
                let allowedMoves = Set(game.board.allowedMoves(coordinate: pieceCoord))
                
                var aroundCoordinates = Set<Coordinate>()
                aroundCoordinates.insert(pieceCoord.getNorth())
                aroundCoordinates.insert(pieceCoord.getEast())
                aroundCoordinates.insert(pieceCoord.getSouth())
                aroundCoordinates.insert(pieceCoord.getWest())
                aroundCoordinates.insert(pieceCoord.getNorthEast())
                aroundCoordinates.insert(pieceCoord.getSouthEast())
                aroundCoordinates.insert(pieceCoord.getSouthWest())
                aroundCoordinates.insert(pieceCoord.getNorthWest())
                
                // Checking that we are not sorrounded by enemies
                for cellAroundPiece in aroundCoordinates {
                    if let nearPiece = game.board.getPiece(at: cellAroundPiece) {
                        if nearPiece.color != AIColor && !nearPiece.isFrozen {
                            score -= (nearPiece.attack.attackStrength + nearPiece.currentVitality) / 2
                        }
                    }
                }
                
                // Give a positive score if we can reach special cells
                if arrayAliveAIPieces.count >= 3 {
                    let movesOnSpCells = allowedMoves.intersection(specialCellsCoordinates)
                    if movesOnSpCells.isEmpty == false {
                        for spCell in movesOnSpCells {
                            // Special cell occupied by an ally
                            if let piece = game.board.getPiece(at: spCell) {
                                if piece.color == AIColor { continue }
                            }
                            // Special cell empty or with an opponent
                            reachableSpCells.insert(spCell)
                        }
                    }
                }
                
                // Check if we can move onto a frozen opponent piece
                for move in allowedMoves {
                    if let piece = game.board.getPiece(at: move) {
                        if !canAlreadyMoveOntoFrozenPly {
                            if piece.color != AIColor && piece.frozenTurnsLeft > 1 {
                                score += 5
                                canAlreadyMoveOntoFrozenPly = true
                                break
                            }
                        }
                        // This is useful to get the pieces closer in a sparse situation (near ending)
                        if piece.color != AIColor {
                            score += 1
                        }
                    }
                }
                
                // Give points if the archer can attack somebody
                if (AIPiece.name == "Archer") {
                    let allowedAttacks = Set(game.board.allowedAttacks(coordinate: pieceCoord))
                    if allowedAttacks.count > 0 {
                        score += 7
                    }
                }
                
                // Give points if the dragon can attack somebody
                if (AIPiece.name == "Dragon") {
                    let allowedAttacks = Set(game.board.allowedAttacks(coordinate: pieceCoord))
                    if allowedAttacks.count > 0 {
                        score += 8
                    }
                }
            }
        }   // End cycling through the AI pieces
        
        
        // Score for having the ability to reach empty or 'occupied by enemy' special cells
        score += reachableSpCells.count * 5
        
        // Penalty for using spells and for let the mage die
        let SPELL_PENALTY = 5
        let spellList: [Spell] = [.freeze, .heal, .revive, .teleport]
        var usedSpells = 0
        
        // Counting the used spells for AI
        for spell in spellList {
            switch AIColor {
            case .white:
                if game.spellWhite[spell] == false {
                    usedSpells += 1
                }
            case .black:
                if game.spellBlack[spell] == false {
                    usedSpells += 1
                }
            }
        }
        
        // Applying the penalty
        if game.isMageAlive(color: AIColor) {
            score -= SPELL_PENALTY * usedSpells
        } else {
            let unusedSpells = spellList.count - usedSpells
            // If all spells are used this formula does not subtract anything
            score -= SPELL_PENALTY * unusedSpells
        }
        
        // Further penalty for using the freeze spell
        if game.isMageAlive(color: AIColor) {
            if AIColor == .white {
                if game.spellWhite[.freeze] == false {
                    score -= 20
                }
                if game.spellWhite[.revive] == false {
                    score -= 7
                }
                if game.spellWhite[.teleport] == false {
                    score -= 5
                }
            } else {
                if game.spellBlack[.freeze] == false {
                    score -= 20
                }
                if game.spellBlack[.revive] == false {
                    score -= 7
                }
                if game.spellBlack[.teleport] == false {
                    score -= 5
                }
            }
        }
        
        // Points for occupying special cells
        var counterIA = 0 , counterOpp = 0
        
        // Counting the special cells occupied by the two factions
        for spCell in game.board.specialCells {
            if let piece = spCell.piece {
                switch piece.color {
                case AIColor:
                    counterIA += 1
                default:
                    counterOpp += 1
                }
            }
        }
        
        // Reward for special cells occupied by AI
        if arrayAliveAIPieces.count >= 3 {
            score += counterIA * 30
        }
        // Penalty for special cells occupied by the player
        if arrayAliveOpponentPieces.count >= 3 {
            score -= counterOpp * 30
        }
        
        return score
    }
}
