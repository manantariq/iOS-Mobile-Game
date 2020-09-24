//
//  AITests.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 22/12/16.
//
//

import XCTest
@testable import MobileApp16


class AITests: XCTestCase {
    var AI: AIPlayer!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        AI = AIMiniMaxPlayer(color: .white, maxDepth: 4)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAIPlayer() {
//        let game: Game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRT")
//        print("Move: \(AI.nextMove(currentGame: game))")
        
        var game: Game?
        //1
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //2
        game = try! gameParser(testString: "W000000000000000M0000D000000a000000003510000000000000000000FHRTFH0T")
        let _ = AI.nextMove(currentGame: game!)
        //3
        game = try! gameParser(testString: "W0000000000m000000000d000000000M0g0002512000000000000000000FH0TFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //4
        game = try! gameParser(testString: "W000000000000000m0000d00K00000sM0g0002512120000000000000000FH0TFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //5
        game = try! gameParser(testString: "W000000000000000m0000d00KM0000000g00s2512120000000000000000FH0TFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //6
        game = try! gameParser(testString: "W000000000m000000000D0K000000000000001120000000000000000000FH0T0H0T")
        let _ = AI.nextMove(currentGame: game!)
        //7
        game = try! gameParser(testString: "W000000000000000m0000M0g0000D0000000011330000000000000000000HRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //8
        game = try! gameParser(testString: "W000000000000000m0K00d000M000000g000s2152120000000000000000FH0TFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //9
        game = try! gameParser(testString: "W000000000000000S000k00000d0000000MD03323200000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //10
        game = try! gameParser(testString: "W000000000000000Sd00000000G0000000s0031130000000000000000000HRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //11
        game = try! gameParser(testString: "W0000000000000000s00000K00kd00000000022110000000000000000000H0TFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //12
        game = try! gameParser(testString: "W00000000000000000000k0000d0M00000D003332000000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //13
        game = try! gameParser(testString: "W000000000000000S0000k0000d0M000000D03323200000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //14
        game = try! gameParser(testString: "W0000000000000000sK0000000000000000002100000000000000000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //15
        game = try! gameParser(testString: "W000000000000000Sd0000000000s000G000031130000000000000000000HRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //16
        game = try! gameParser(testString: "Wa00000000000000000000000000000000D003100000000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //17
        game = try! gameParser(testString: "W0000000000000000000000000000a00M000014000000000000000000000HRTFHR0")
        let _ = AI.nextMove(currentGame: game!)
        //18
        game = try! gameParser(testString: "W000000a00000000000000000000000D00K003520000000000000000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //19
        game = try! gameParser(testString: "W000000000000000000000a00g0000K00000k2213000000000000000000F0RT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //20
        game = try! gameParser(testString: "W0000000000000000000000M00a000000000021000000000000000000000HRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //21
        game = try! gameParser(testString: "W000000000000000S0000k0000d0M000000D03323200000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //22
        game = try! gameParser(testString: "W0000000000000000sK0000000000000000002100000000000000000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //23
        game = try! gameParser(testString: "W000000000000000Sd0000000000s000G000031130000000000000000000HRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //24
        game = try! gameParser(testString: "Wa00000000000000000000000000000000D003100000000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //25
        game = try! gameParser(testString: "W0000000000000000000000000000a00M000014000000000000000000000HRTFHR0")
        let _ = AI.nextMove(currentGame: game!)
        //26
        game = try! gameParser(testString: "W000000a00000000000000000000000D00K003520000000000000000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //27
        game = try! gameParser(testString: "W000000000000000000000a00g0000K00000k2213000000000000000000F0RT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //28
        game = try! gameParser(testString: "W0000000000000000000000M00a000000000021000000000000000000000HRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //29
        game = try! gameParser(testString: "W0000000000000000000000M0000a00000D001350000000000000000000FHRTFH0T")
        let _ = AI.nextMove(currentGame: game!)
        //30
        game = try! gameParser(testString: "W00000000000000000000S0a00000s00000k01222000000000000000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
        //31
        game = try! gameParser(testString: "W0000000000000000000ad00000g0GD0k00004112440000000000000000FHR00HRT")
        let _ = AI.nextMove(currentGame: game!)
        //32
        game = try! gameParser(testString: "W000000a0000000A0000D0000000000M000001232000000000000000000FHRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //33
        game = try! gameParser(testString: "W0000000000000kA0000000000000a000000D32210000000000000000000H0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //34
        game = try! gameParser(testString: "W00000000000000A000k0000D000a0s000M0032214100000000000000000H0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //35
        game = try! gameParser(testString: "W00000000000000A000k0000D000a0000M00032123000000000000000000H0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        //36
        game = try! gameParser(testString: "W0000000000000000D00a00000000000000003100000000000000000000FH0T0HRT")
        let _ = AI.nextMove(currentGame: game!)
        
        //        game = try! gameParser(testString: "")
        //        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer2() {
        var game: Game?
        //initial configuration
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer3() {
        var game: Game?
        //initial configuration no revive
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FH0TFH0T")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer4() {
        var game: Game?
        //initial configuration no teleport
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000FHR0FHR0")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer5() {
        var game: Game?
        //initial configuration no freeze
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg00000056754343343457650000000HRT0HRT")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer6() {
        var game: Game?
        //initial configuration no heal
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg0000005675434334345765000000F0RTF0RT")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer7() {
        var game: Game?
        //initial configuration no spell
        game = try! gameParser(testString: "W000000GK00saDS00kmMK00sdAS00kg000000567543433434576500000000000000")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer8() {
        var game: Game?
        //initial configuration no spell
        game = try! gameParser(testString: "W000000GK00000000000000000000kg0000003333000000000000000000FHR0FHR0")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer9() {
        var game: Game?
        //initial configuration no spell
        game = try! gameParser(testString: "W000000GK00000000000000000000kg0000003333000000000000000000FHR0FHR0")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer10() {
        var game: Game?
        //already won game
        game = try! gameParser(testString: "W000000GK00000000000000000000000000003300000000000000000000FHR0FHR0")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer11() {
        var game: Game?
        //win in one move for white
        game = try! gameParser(testString: "WM00S0000000a00K000000s0000000m0A000g2122132400000000000000FHRTFHRT")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer12() {
        var game: Game?
        //initial configuration no spell
        game = try! gameParser(testString: "W000000GKDM000000000000000000gkdms0003333333330000000000000FHR0FHR0")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    func testAIPlayer13() {
        var game: Game?
        //White will loose
        game = try! gameParser(testString: "W000000000000000000000000000Sg00000003500000000000000000000FHR0FHR0")
        let _ = AI.nextMove(currentGame: game!)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
