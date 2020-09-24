//
//  BoardTests.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 16/11/16.
//
//

import XCTest
@testable import MobileApp16

class BoardTests: XCTestCase {
    var board: Board!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleDescription() {
        let boardConfiguration = "000000GK00saDS00kmMK00sdAS00kg000000"
        
        do {
            board = try legacyBoardParser(boardConfiguration)
        } catch {
            XCTFail("Invalid board configuration provided")
            return
        }
        
        XCTAssertEqual(boardConfiguration, board.description)
    }
    
    func testMovePiece() {
        let testStrings = [ "000000GK00saDS00kmMK00sdAS00kg000000#10-01#0G00000K00saDS00kmMK00sdAS00kg000000",     // W-Giant move in empty cell
            "000000GK00saDS00kmMK00sdAS00kg000000#45-35#000000GK00saDS00kmMK00sdAS00kg000000" ]    // B-Giant move in occupied cell
        
        for testString in testStrings {
            var componentsArray = testString.components(separatedBy: "#")
            let startingBoardConfiguration = componentsArray[0]
            let stringCoordinates = componentsArray[1].components(separatedBy: "-")
            let endingBoardConfiguration = componentsArray[2]
            
            do {
                board = try legacyBoardParser(startingBoardConfiguration)
            } catch {
                XCTFail("Invalid board configuration provided")
                return
            }
            
            let fromCoordinate = Coordinate(Int(stringCoordinates.first![0])!, Int(stringCoordinates.first![1])!)
            let toCoordinate = Coordinate(Int(stringCoordinates.last![0])!, Int(stringCoordinates.last![1])!)
            
            let success = board.movePiece(startingCoordinate: fromCoordinate, endingCoordinate: toCoordinate)
            
            XCTAssertEqual(success, startingBoardConfiguration != endingBoardConfiguration)
            XCTAssertEqual(endingBoardConfiguration, board.description)
        }
    }
    
    func testAllowedMoves() {
        
        // Format "BoardConfiguration(#Piece-AssertedMoves*)+"
        let testStrings = [ // Initial Configuration Whites
                            "000000GK00saDS00kmMK00sdAS00kg000000#10-0001#20-00011222233250#30-#40-50515242#11-0001021222#21-22#31-223242#41-4251",
                            // Initial Configuration Blacks
                            "000000GK00saDS00kmMK00sdAS00kg000000#15-05040313#25-#35-55544333322305#45-5554#14-1304#24-132333#34-33#44-5554534333",
                            "00000000K0saDSGk0mMK00sdAS00kg000000#22-23333242",                 // Slide's example of walk
                            "000000GK00saDSk00mMK00sdAS00kg000000#20-00011222233250",           // Slide's example of flight
                            "000000GK00saDSk00mM0Ks0d0SAk000000g0#42-3343534454525150312240"    // Slide's example of diagonal walk
                          ]
        
        
        for testString in testStrings {
            var componentsArray = testString.components(separatedBy: "#")
            let boardConfiguration = componentsArray.first!
            
            do {
                board = try legacyBoardParser(boardConfiguration)
            } catch {
                XCTFail("Invalid board configuration provided")
                return
            }
            
            componentsArray.remove(at: 0)
            
            print("Testing Board Configuration: \(boardConfiguration)")
            for test in componentsArray {
                let piece = test.components(separatedBy: "-").first!
                let assertions = test.components(separatedBy: "-").last!
                
                let highlitedPiece = Coordinate(Int(piece[0])!, Int(piece[1])!)
                
                var index = 0
                var assertedMoves: Set<Coordinate> = Set()
                while index < assertions.lengthOfBytes(using: .ascii) {
                    assertedMoves.insert(Coordinate(Int(assertions[index])!, Int(assertions[index+1])!))
                    index += 2
                }
                
                
                // EXECUTING TEST
                let allowedMoves = Set(board.allowedMoves(coordinate: highlitedPiece))
                print("\t testing piece: \(highlitedPiece)")
                print("\t\t asserted: \(assertedMoves)")
                print("\t\t computed: \(allowedMoves)")
                
                XCTAssertEqual(allowedMoves, assertedMoves)
            }
        }
        
    }
    
    func testAllowedAttacks() {
        
        // Format "BoardConfiguration(#Piece-AssertedAttacks*)+"
        let testStrings = [ "00000000Ks0aDSGk0mMKs00dAS00kg000000#22-2332",     // Slide's example of Giant attack
                            "0000000KGs0a0S0k0mMKA0sd0Sk0000Dg000#32-3442",     // Slide's example of Archer attack
                            "0000000KGsSa00Kk0mM0A0sd0S000g0D0000#23-121432" ]  // Slide's example of knight attack
        
        
        for testString in testStrings {
            var componentsArray = testString.components(separatedBy: "#")
            let boardConfiguration = componentsArray.first!
            
            do {
                board = try legacyBoardParser(boardConfiguration)
            } catch {
                XCTFail("Invalid board configuration provided")
                return
            }
            
            componentsArray.remove(at: 0)
            
            print("Testing Board Configuration: \(boardConfiguration)")
            for test in componentsArray {
                let piece = test.components(separatedBy: "-").first!
                let assertions = test.components(separatedBy: "-").last!
                
                let highlitedPiece = Coordinate(Int(piece[0])!, Int(piece[1])!)
                
                var index = 0
                var assertedAttacks: Set<Coordinate> = Set()
                while index < assertions.lengthOfBytes(using: .ascii) {
                    assertedAttacks.insert(Coordinate(Int(assertions[index])!, Int(assertions[index+1])!))
                    index += 2
                }
                
                
                // EXECUTING TEST
                let allowedAttacks = Set(board.allowedAttacks(coordinate: highlitedPiece))
                print("\t testing piece: \(highlitedPiece)")
                print("\t\t asserted: \(assertedAttacks)")
                print("\t\t computed: \(allowedAttacks)")
                
                XCTAssertEqual(allowedAttacks, assertedAttacks)
            }
        }

    }
    
    
    /// Parse coordinates in the form "(x,y)(x,y)..."
    static func stringToCoordinate(_ string: String) -> [Coordinate] {
        var parsingString = string
        parsingString.remove(at: string.startIndex)
        parsingString.remove(at: parsingString.index(before: parsingString.endIndex))
        
        var coordinateArray: [Coordinate] = []
        for singleCoord in parsingString.components(separatedBy: ")(") {
            let components = singleCoord.components(separatedBy: ",")
            coordinateArray += [Coordinate(Int(components[0])!, Int(components[1])!)]
        }
        
        return coordinateArray
    }
    
}
