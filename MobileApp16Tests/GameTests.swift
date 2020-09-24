//
//  GameTests.swift
//  MobileApp16Tests
//
//  Created by Ilaria Carlini on 03/11/16.
//
//

import XCTest

class GameTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGameCreation() {
        do {
            let game = try gameParser(testString: "W00000000Ks0000Gk0000ks000000000000002222220000000000000000FHRTFHRT")
            
            XCTAssertEqual(game.pieces.filter ({$0.currentVitality==0}).count, 10)
        } catch {
            print(error)
        }
        
    }
    
    /// Testing movement in a free cell and movement in a occupied cell (also performing combat)
    func testPlayMove() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN: testing movement in a free ending coordinatE
        let _ = game.play(startingCoordinate: Coordinate(2,0), endingCoordinate: Coordinate(2,3), action: .move, piece: nil)
        // BLACK TURN: testing movement in the cell occupied by the dragon + combat
        let _ = game.play(startingCoordinate: Coordinate(2,4), endingCoordinate: Coordinate(2,3), action: .move, piece: nil)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,3))?.name, "Dragon")
    }
    
    /// testing that white pieces can be moved only in white's turn and viceversa
    func testPlayMoveAnEnemyPiece() {
        var game = Game()
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN: trying to move a black squire from its initial position (1,4) to (1,3)
        let _ = game.play(startingCoordinate: Coordinate(1,4), endingCoordinate: Coordinate(1,3), action: .move, piece: nil)
        XCTAssertNil(game.board.getPiece(at: Coordinate(1,3)), "You cannot move an enemy's piece")
        
        // WHITE TURN: I move the white dragon near the black knight
        let _ = game.play(startingCoordinate: Coordinate(2,0), endingCoordinate: Coordinate(2,3), action: .move, piece: nil)
        // BLACK TURN: I try to attack a black piece
        let _ = game.play(startingCoordinate: Coordinate(2,3), endingCoordinate: Coordinate(2,4), action: .attack, piece: nil)
        // The vitality of the attacked piece has to be its initial vitality
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,4))?.currentVitality, 4)
    }
    
    /// Moving the white giant from its starting coordinate (1,0) to (5,3) -> this coordinate is not allowed from (1,0)
    func testPlayMoveInNotAllowedCoordinates() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        let _ = game.play(startingCoordinate: Coordinate(1,0), endingCoordinate: Coordinate(5,3), action: .move, piece: nil)
        
        XCTAssertNil(game.board.getPiece(at: Coordinate(5,3)), "You cannot move this piece on this coordinate")
    }
    
    /// Moving a frozen piece
    func testPlayMoveFrozenPiece() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        let whiteSquire = game.board.getPiece(at: Coordinate(2,1))
        whiteSquire!.frozenTurnsLeft = 3
        
        let _ = game.play(startingCoordinate: Coordinate(2,1), endingCoordinate: Coordinate(2,2), action: .move, piece: nil)
        
        XCTAssertNil(game.board.getPiece(at: Coordinate(2,2)), "You cannot move this piece: is frozen!")
    }
    
    /// testing action 'attack'
    func testPlayAttack() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN: movement in a free ending coordinate
        let _ = game.play(startingCoordinate: Coordinate(2,0), endingCoordinate: Coordinate(2,3), action: .move, piece: nil)
        // BLACK TURN
        let _ = game.play(startingCoordinate: Coordinate(4,4), endingCoordinate: Coordinate(4,3), action: .move, piece: nil)
        // WHITE TURN
        let _ = game.play(startingCoordinate: Coordinate(2,3), endingCoordinate: Coordinate(2,4), action: .attack, piece: nil)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,4))?.currentVitality, 1)
    }
    /// Testing an attack to a frozen piece
    func testPlayAttackToFrozenPiece() {
        do {
            var game = try gameParser(testString: "W0Aa00000000000000000Gg000000000000002244000000000000000443FHRTFHRT")
            let _ = game.play(startingCoordinate: Coordinate(3,2), endingCoordinate: Coordinate(3,3), action: .attack, piece: nil)
            
            XCTAssertNil(game.board.getPiece(at: Coordinate(3,3)), "The attacked piece was frozen, so now is dead")
        } catch {
            print(error)
        }
    }
    
    /// Testing an attack from a frozen piece
    func testPlayAttackFromFrozenPiece() {
        do {
            var game = try gameParser(testString: "W0Aa00000000000000000Gg000000000000002244000000000000343000FHRTFHRT")
            let _ = game.play(startingCoordinate: Coordinate(3,2), endingCoordinate: Coordinate(3,3), action: .attack, piece: nil)
            
            // Since the attack has not been successful, the vitality of the piece is the same passed in the string (4)
            XCTAssertEqual(game.board.getPiece(at: Coordinate(3,3))?.currentVitality, 4)
        } catch {
            print(error)
        }
    }
    
    /// Testing an attack between two pieces of the same turn: the attack hasn't been performed, the vitality of the piece in (1,1) is its initial vitality.
    func testPlayAttackFriend() {
        var game = Game()
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        let _ = game.play(startingCoordinate: Coordinate(1,0), endingCoordinate: Coordinate(1,1), action: .attack, piece: nil)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(1,1))?.currentVitality, game.board.getPiece(at: Coordinate(1,1))?.initialVitality)
        XCTAssertEqual(game.turn, .white)
    }
    
    /// Testing that G can attacks only the two knights and not the squires;
    /// testing that the K can attacks only diagonal.
    /// K | s
    /// G | k
    /// k | s
    func testAttackOneDirectionOnly() {
        do {
            var game = try gameParser(testString: "W00000000Ks0000Gk0000ks000000000000002222220000000000000000FHRTFHRT")
            
            let movesGiant: Set<Coordinate> = [Coordinate(3,2), Coordinate(2,3)]
            let allowedAttacksGiant = Set(game.board.allowedAttacks(coordinate: Coordinate(2,2)))
            let _ = game.play(startingCoordinate: Coordinate(2,2), endingCoordinate: Coordinate(3,3), action: .attack, piece: nil)
            // Check that attack has not been performed
            XCTAssertEqual(game.board.getPiece(at: Coordinate(3,3))?.currentVitality, 2)
            XCTAssertEqual(allowedAttacksGiant, movesGiant)
            
            let movesKnight: Set<Coordinate> = [Coordinate(2,3)]
            let allowedAttacksKnight = Set(game.board.allowedAttacks(coordinate: Coordinate(1,2)))
            let _ = game.play(startingCoordinate: Coordinate(1,2), endingCoordinate: Coordinate(1,3), action: .attack, piece: nil)
            // Check that attack has not been performed
            XCTAssertEqual(game.board.getPiece(at: Coordinate(1,3))?.currentVitality, 2)
            XCTAssertEqual(allowedAttacksKnight, movesKnight)
        } catch {
            print(error)
        }
    }
    
    /// Testing a combat between frozen pieces
    func testPlayCombatBetweenFrozenPieces() {
        do {
            var game = try gameParser(testString: "W0Ms00000000000000000Gg000000000000002251000000000000343443FHRTFHRT")
            let _ = game.play(startingCoordinate: Coordinate(3,2), endingCoordinate: Coordinate(3,3), action: .spell(.teleport), piece: nil)
            XCTAssertNil(game.board.getPiece(at: Coordinate(3,2)), "The move action has been performed")
            XCTAssertNil(game.board.getPiece(at: Coordinate(3,3)), "Both pieces were frozen, so now are dead")
        } catch {
            print(error)
        }
    }
    
    /// Testing that a spell can be casted only if the mage is alive and not frozen
    func testSpellMageAliveAndNotFrozen() {
        do {
            var game = try gameParser(testString: "W00000000Ks00M0Gk0000ks000000000000002222222000000000133000FHRT0HRT")
            let _ = game.play(startingCoordinate: Coordinate(1,3), endingCoordinate: nil, action: .spell(.freeze), piece: nil)
            XCTAssertEqual(game.spellWhite[.freeze], true)
        } catch {
            print(error)
        }
    }
    
    func testPlaySpellHeal() {
        var game = Game()
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN: movement in a free ending coordinate
        let _ = game.play(startingCoordinate: Coordinate(2,0), endingCoordinate: Coordinate(2,3), action: .move, piece: nil)
        // BLACK TURN: movement in a free ending coordinate
        let _ = game.play(startingCoordinate: Coordinate(4,4), endingCoordinate: Coordinate(4,3), action: .move, piece: nil)
        // WHITE TURN: white dragon attack a black knight
        let _ = game.play(startingCoordinate: Coordinate(2,3), endingCoordinate: Coordinate(2,4), action: .attack, piece: nil)
        // BLACK TURN: heal on the black knight
        let _ = game.play(startingCoordinate: Coordinate(2,4), endingCoordinate: nil, action: .spell(.heal), piece: nil)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,4))?.currentVitality, 4)
        XCTAssertEqual(game.spellBlack[.heal], false)
    }
    
    func testPlaySpellHealToAFullLifePiece() {
        var game = Game()
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        let _ = game.play(startingCoordinate: Coordinate(1,0), endingCoordinate: nil, action: .spell(.heal), piece: nil)
        
        XCTAssertEqual(game.spellWhite[.heal], true)
    }
    
    
    /// testing the correctness of the freeze spell: it must set the frozen turn left of the enemy's piece at 3
    func testPlaySpellFreeze() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN: freeze the piece on coordinate (1,4), a black squire
        let _ = game.play(startingCoordinate: Coordinate(1,4), endingCoordinate: nil, action: .spell(.freeze), piece: nil)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(1,4))?.frozenTurnsLeft, 3)
        XCTAssertEqual(game.spellWhite[.freeze], false)
    }
    
    func testPlaySpellTeleport() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN: teleport the white dragon to a free ending coordinate
        let _ = game.play(startingCoordinate: Coordinate(2,0), endingCoordinate: Coordinate(0,5), action: .spell(.teleport), piece: nil)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(0,5))?.name, "Dragon")
        XCTAssertEqual(game.spellWhite[.teleport], false)
    }
    
    func testPlaySpellRevive() {
        var game = Game()
        
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        let whiteDragon = game.board.getPiece(at: Coordinate(2,0))
        whiteDragon?.currentVitality = 0
        let _  = game.board.removePiece(from: Coordinate(2,0))
        
        // WHITE TURN: revive the white dragon
        let _ = game.play(startingCoordinate: nil, endingCoordinate: nil, action: .spell(.revive), piece: whiteDragon)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,0))?.name, "Dragon")
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,0))?.currentVitality, 6)
        XCTAssertEqual(game.spellWhite[.revive], false)
    }
    
    /// Testing a revive on a frozen piece: checking its current vitality and its frozen turn left (((((DA VEDERE)))))
    func testPlaySpellReviveFrozenPiece() {
        do {
            var game = try gameParser(testString: "W000Mm000000000000000G0g00000000000002424000000000000343543FHRTFHRT")
            
            // Black giant
            let blackGiant = game.board.getPiece(at: Coordinate(3,4))
            let _ = game.play(startingCoordinate: Coordinate(3,2), endingCoordinate: Coordinate(3,4), action: .spell(.teleport), piece: nil)
            let _ = game.play(startingCoordinate: nil, endingCoordinate: nil, action: .spell(.revive), piece: blackGiant)
            
            XCTAssertEqual(game.board.getPiece(at: Coordinate(4,5))?.name, "Giant")
            XCTAssertEqual(game.board.getPiece(at: Coordinate(4,5))?.frozenTurnsLeft, 0)
            XCTAssertEqual(game.board.getPiece(at: Coordinate(4,5))?.currentVitality, 5)
        } catch {
            print(error)
        }
    }
    
    /// Testing the revive spell for a piece whose occurrency is more than one in a game.
    /// The initial position is occupied, and the piece is revitalized in the twin's initial position.
    func testPlaySpellReviveTwin() {
        var game = Game()
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        let testKnight1 = game.board.getPiece(at: Coordinate(4,4))!
        testKnight1.currentVitality = 0
        let _ = game.board.removePiece(from: Coordinate(4,4))
        
        // WHITE TURN
        let _ = game.play(startingCoordinate: Coordinate(1,0), endingCoordinate: Coordinate(0,0), action: .move, piece: nil)
        // BLACK TURN
        let _ = game.play(startingCoordinate: Coordinate(3,4), endingCoordinate: Coordinate(4,4), action: .move, piece: nil)
        // WHITE TURN
        let _ = game.play(startingCoordinate: Coordinate(0,0), endingCoordinate: Coordinate(0,1), action: .move, piece: nil)
        // BLACK TURN
        let _ = game.play(startingCoordinate: Coordinate(2,4), endingCoordinate: Coordinate(2,3), action: .move, piece: nil)
        // WHITE TURN
        let _ = game.play(startingCoordinate: Coordinate(0,1), endingCoordinate: Coordinate(0,2), action: .move, piece: nil)
        // BLACK TURN
        let _ = game.play(startingCoordinate: nil, endingCoordinate: nil, action: .spell(.revive), piece: testKnight1)
        
        XCTAssertEqual(game.board.getPiece(at: Coordinate(2,4))?.name, "Knight")
        XCTAssertEqual(game.spellBlack[.revive], false)
    }
    
    // Testing the revive on the other cell of a duplicated piece
    func testSpellReviveOnOtherCell() {
        let game = "B000000GK00kaDS000mMK000dAS00kg0000005675434344576500000000FHRTFHRTR5200"
        
        let finalBoard = "W000000GK00kaDS000mMK00sdAS00kg0000005675434343457650000000FHRTFH0T"
        XCTAssertEqual(finalBoard, turnTest(testString: game))
    }
    
    // Testing the revive on the other cell of a duplicated piece while that cell is occupied by an enemy piece
    func testSpellReviveOnOtherCellWithCombat() {
        let game = ["B000000GK00kaD0000mMK00SdAS00kg0000005675443434576500000000FHRTFHRTR5200",
                    "B000000GK00kaD0000mMK00SdAS00kg0000005675443424576500000000FHRTFHRTR5200",
                    "B0000000K00kaD0000mMK00GdAS00kg0000006754434545765000000000FHRTFHRTR5200"]
        
        let finalBoard = ["W000000GK00kaD0000mMK000dAS00kg0000005675443445765000000000FHRTFH0T",
                          "W000000GK00kaD0000mMK00sdAS00kg0000005675443414576500000000FHRTFH0T",
                          "W0000000K00kaD0000mMK00GdAS00kg0000006754434445765000000000FHRTFH0T"]
    
        for i in 0..<game.count {
            XCTAssertEqual(finalBoard[i], turnTest(testString: game[i]))
        }
    }
    
    // Impossible Revive
    func testSpellReviveImpossible() {
        let game = "B000000GK00kaDS000mMK00kdAS000g0000005675434344576500000000FHRTFHRTR5200"
        
        let finalBoard = "B000000GK00kaDS000mMK00kdAS000g0000005675434344576500000000FHRTFHRT"
        XCTAssertEqual(finalBoard, turnTest(testString: game))
    }
    
    /// Trying to re-use a spell (freeze) in the same game
    func testDoubleUseSpell() {
        var game = Game()
        game.startGame(player1: Player(name: "Player 1", turn: .white, win: 0, draw: 0), player2: Player(name: "Player 2", turn: .black, win: 0, draw: 0))
        
        // WHITE TURN
        let _ = game.play(startingCoordinate: Coordinate(1,5), endingCoordinate: nil, action: .spell(.freeze), piece: nil)
        // BLACK TURN: trying to move a frozen piece
        let _ = game.play(startingCoordinate: Coordinate(1,5), endingCoordinate: Coordinate(0,5), action: .move, piece: nil)
        let _ = game.play(startingCoordinate: Coordinate(1,4), endingCoordinate: Coordinate(0,4), action: .move, piece: nil)
        // WHITE TURN
        let _ = game.play(startingCoordinate: Coordinate(1,5), endingCoordinate: nil, action: .spell(.freeze), piece: nil)
        
        // la spell non è stata eseguita: il turno è ancora bianco
        XCTAssertEqual(game.turn, .white)
        XCTAssertEqual(game.spellWhite[.freeze], false)
    }
    
    /// Test a win using special cells: at the beginning of the test the special cells are occupied by 2 white pieces.
    /// With the movement, a third white piece occupy another special cell.
    /// The global variable 'isGameEnded' turn true and the winner is setted in the global variable 'winner'.
    func testWinBySpecialCells() {
        do {
            var game = try gameParser(testString: "WG00S0000000a00K000000s0000000m0A000g2122132400000000000000FHRTFHRT")
            let _ = game.play(startingCoordinate: Coordinate(5,1), endingCoordinate: Coordinate(5,2), action: .move, piece: nil)
            
            XCTAssertEqual(game.isGameEnded, true)
        } catch {
            print(error)
        }
    }
    
    /// Example of end game on the slides which return that black wins (p.19 from slides)
    func testWin() {
        do {
            var game = try gameParser(testString: "B000000000000000k0m0000M00000000000002220000000000000000431FHRTFHRT")
            let _ = game.play(startingCoordinate: Coordinate(2,5), endingCoordinate: Coordinate(3,4), action: .move, piece: nil)
            
            XCTAssertEqual(game.isGameEnded, true)
            XCTAssertEqual(game.winner, .black)
        } catch {
            print(error)
        }
    }
    
    /// Testing a possible ending in which two pieces have a combat and die (in the same turn); they are the only two pieces on the board.
    func testDraw() {
        do {
            var game = try gameParser(testString: "B00000000000000000000Gg000000000000004400000000000000000000FHRTFHRT")
            let _ = game.play(startingCoordinate: Coordinate(3,3), endingCoordinate: Coordinate(3,2), action: .move, piece: nil)
            
            XCTAssertNil(game.board.getPiece(at: Coordinate(3,2)), "There is no piece in this cell")
            XCTAssertEqual(game.isGameEnded, true)
            XCTAssertEqual(game.winner, nil)
        } catch {
            print(error)
        }
    }
    
    /// Example of end game on the slides which return a draw (p.18 from slides)
    func testDraw2() {
        do {
            let testString = "W000000000000000k0m0000M00000000000002220000000000000000431FHRTFHRTM5463"
            
            var game = try gameParser(testString: testString)
            let _ = game.play(startingCoordinate: Coordinate(3,4), endingCoordinate: Coordinate(2,5), action: .move, piece: nil)
            
            XCTAssertEqual(game.isGameEnded, true)
            XCTAssertEqual(game.winner, nil)
            
            let result = turnTest(testString: testString)
            
            XCTAssertEqual(result, "B000000000000000k000000000000000000002000000000000000000431FHRTFHRTDRAW")
        } catch {
            print(error)
        }
    }
    
    /// testing the allowed moves for a dragon
    func testDragonMove() {
        do {
            let game = try gameParser(testString: "B00000000K0saDSGk0mMK00sdAS00kg0000006753434543345765000000FHRTFHRT")
            let moves: Set<Coordinate> = [Coordinate(0,0), Coordinate(0,1), Coordinate(1,0), Coordinate(1,1), Coordinate(2,3), Coordinate(3,2), Coordinate(5,0)]
            let allowedMoves = Set(game.board.allowedMoves(coordinate: Coordinate(2,0)))
            
            XCTAssertEqual(allowedMoves, moves)
        } catch {
            print(error)
        }
    }
    
    /// testing the allowed attack for a dragon.
    /// In this specific test I'm testing that a piece cannot attack an enemy if between them there is another piece
    /// D -> G -> k
    func testDragonAttack() {
        do {
            var game = try gameParser(testString: "W00000000K0saSDGk0mMK00sdAS00kg0000003753464543345765000000FHRTFHRT")
            let moves: Set<Coordinate> = []
            let allowedAttacks = Set(game.board.allowedAttacks(coordinate: Coordinate(2,1)))
            
            let _ = game.play(startingCoordinate: Coordinate(2,1), endingCoordinate: Coordinate(2,3), action: .attack, piece: nil)
            XCTAssertEqual(allowedAttacks, moves)
        } catch {
            print(error)
        }
    }
    
    // Test telereport after being attacked and combat after being attacked
    func testWeakPiece() {
        let game = "W0000s0GK000aDS00kmMK00sd0SA0kg0000005674343534345765000000FHRTFHRTA3555T5521A3565M6555A3555M5545M3545"
        
        let finalBoard = "B0k00s0GK000aDS00kmMK00sd0S0A000000005672434313435760000000FHRTFHR0"
        XCTAssertEqual(finalBoard, turnTest(testString: game))
    }
    
    /// Testing a full game (black wins by special cells)
    func testPlayFullGame() {
        let gameString = "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRTM2435T6415M1315M5544A3544M6242M2333A4222M2231A4435A3142M4231M1536M5242A3544M4241M1232F3200M3646M3111F6500R6400M4666M6466"
        
        let finalBoard = "Wa00s0000G00000S0kmM000s00SK00g00000d17353234375300000006510HRT0H00BLACK"
        XCTAssertEqual(finalBoard, turnTest(testString: gameString))
    }
    
    /// Testing a full game (white wins by special cells)
    func testPlayFullGame2() {
        let gameString = "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRTM1211F1300M1535T6524A3555M2423M3536M2313M2231M6241R2400A4131H3100A4131T2442M5444M3141M6443F4400R6500M1321M5251A2141M5141M4241"
        
        let finalBoard = "BGD0K00000000000dkmM00s000S00kg00A000572352634275000000000000000H00WHITE"
        XCTAssertEqual(finalBoard, turnTest(testString: gameString))
    }
    
    /// Testing a full game (draw due to stall of frozen pieces)
    func testPlayFullGame3() {
        let gameString = "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRTM2232M5242M3242A5342M1333M5545A3353M6444A3353A4424M1232A4424M2535M4535T3265R6500R1200T6512A1535M6242M1535M4435M3342H3500H4200M3523M4254M6353M1424M5343M2434M4344F2300F5400M3444"
        
        let finalBoard = "B0000000000000d00000000D0000000000000550000000000000054223200000000DRAW"
        XCTAssertEqual(finalBoard, turnTest(testString: gameString))
    }
    
    func testGameParser() {
        
        var testString: String
        var parser: String
        
        //Initial test plus move
        testString = "W000000GK00saDS00kmMK00sdAS00kg000000567543433434576500000000000000M1221"
        parser = turnTest(testString: testString)
        XCTAssertEqual("B0G00000K00saDS00kmMK00sdAS00kg000000675543433434576500000000000000", parser)
        //XCTAssertThrowsError(turnTest(testString: testString))
        
        //Allowed move that lead to victory WHITE followed by a move at game over (not considered)
        testString = "WM00S0000000a00K000000s0000000m0A000g2122132400000000000000FHRTFHRTM2636M6263"
        parser = turnTest(testString: testString)
        XCTAssertEqual("BM00S0000000a00K000000s0000000m00A00g2212132400000000000000FHRTFHRTWHITE", parser)
        
        //diagonal unallowed move
        testString = "W000000S0K00a0M00000000km00000000S00g3212223200000000000000FHRTFHRTM1221"
        parser = turnTest(testString: testString)
        XCTAssertEqual("W000000S0K00a0M00000000km00000000S00g3212223200000000000000FHRTFHRT", parser)
        
        //diagonal allowed move
        testString = "W000000S0K00a0M00000000km00000000S00g3212223200000000000000FHRTFHRTM3241"
        parser = turnTest(testString: testString)
        XCTAssertEqual("B000K00S0000a0M00000000km00000000S00g3221223200000000000000FHRTFHRT", parser)
        
        //WHITE win check
        testString = "WM00S0000000a00K000000s0000000m0A000g2122132400000000000000FHRTFHRTM2636"
        parser = turnTest(testString: testString)
        XCTAssertEqual("BM00S0000000a00K000000s0000000m00A00g2212132400000000000000FHRTFHRTWHITE", parser)
        testString = "W000000S0K00a0M00000000km00000000S00g3212223200000000000000FHRTFHRTM1211M6261M3241"
        parser = turnTest(testString: testString)
        XCTAssertEqual("BS00K0a0000000M00000000km00000000S00g3221223200000000000000FHRTFHRTWHITE", parser)
        
        //Draw
        testString = "WGg00000000000000000000000000000000001100000000000000000000FHRTFHRTM1121"
        parser = turnTest(testString: testString)
        XCTAssertEqual("B0000000000000000000000000000000000000000000000000000000000FHRTFHRTDRAW", parser)
        
        //Dragon flight
        testString = "W000000GK00saDS00kmMK00sdAS00kg000000567543433434576500000000000000M1343"
        parser = turnTest(testString: testString)
        XCTAssertEqual("B000000GK00sa0S0DkmMK00sdAS00kg000000575434363434576500000000000000", parser)
        
    }
    
    func testUndoMove() {
        let testString = "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRTM2232M5242M3242A5342M1333M5545A3353M6444A3353A4424M1232A4424M2535M4535T3265R6500R1200T6512A1535M6242M1535M4435M3342H3500H4200M3523M4254M6353M1424M5343M2434M4344F2300F5400M3444"
        //let testString = "B0K000k00K0s0G000000S000000MmAd0kga0s2223221531212100000000F0RTF0RTM4556M3243M5253M2112M6564M3536A4643M1322M6162M2223M2635M2313M6261A5556M4626M1333M6665M1222M5655M2211M6566M2425M6152M1122M6665M2232M2616M3241M1615M2524M3545M3322M5363A4152M1536M2221M6353M2131M4534M3121M5343M2132M3614M4142M6463M4241M6342M2425M6566M2515M6656M3242M1416M4131M1635M1525M5666M3121M5564M2526M6465M2636M3554M3626M6564M2636M6455M2111M3445M1122M5453M3635M4333M3536M5544M2233M6656M3332M5364M3221M5646M3626M6452M2111M4455M2636M4556M1122M4636M2232M5564M3626M5234M3231M6455M2625M5546M2515M4636M3121"
        
        let testStringLength = testString.characters.count
        var moveCounter = 0
        repeat {
            let gameString = testString[0, testStringLength - moveCounter * 5]
            let prevGameString = gameString[0, testStringLength - (moveCounter + 1) * 5]
                        
            var game = try? gameParser(testString: gameString)
            let prevGame = try? gameParser(testString: prevGameString)
            
            game?.undoMove()
            
            XCTAssertEqual(game?.description, prevGame?.description)
            
            moveCounter += 1
        } while (testStringLength - moveCounter * 5) > 67
    }
}
