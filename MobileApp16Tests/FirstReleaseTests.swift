//
//  FirstReleaseTests.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 17/12/16.
//
//

import XCTest
import Foundation

class FirstReleaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFirstRelease() {
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: "firstReleaseTests", ofType: "txt") {
            var testCount = 0
            do {
                let data = try String(contentsOfFile: path, encoding: .ascii)
                let myStrings = data.components(separatedBy: .newlines)
                for testLine in myStrings {
                    guard !testLine.isEmpty else { continue }
                    testCount += 1
                    let components = testLine.components(separatedBy: ",")
                    XCTAssertEqual(turnTest(testString: components[0]), components[1], "Line \(testCount)")
                }
                print("First Release Test: \(testCount) tests performed.")
            } catch {
                print("\(error) while processing line \(testCount)")
            }
        } else {
            print("File not found!")
        }
    }
    
}
