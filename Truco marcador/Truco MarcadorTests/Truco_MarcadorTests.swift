//
//  Truco_MarcadorTests.swift
//  Truco MarcadorTests
//
//  Created by Joao Flores on 13/01/20.
//  Copyright © 2020 Gustavo Lima. All rights reserved.
//

@testable import Truco_Marcador
import XCTest

var sut: TrucoViewController!

class Truco_MarcadorTests: XCTestCase {
    
    var sut: PointsClass!
    
    override func setUp() {
        super.setUp()
        sut = PointsClass()
        sut.initGame()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testRoundIsComputedSum3() {
        sut.roundT1 = sut.sum3(round: sut.roundT1)
        XCTAssertEqual(sut.roundT1, 3, "Score computed is wrong")
    }
    
    func testRoundIsComputedSum1() {
        sut.roundT1 = sut.sum1(round: sut.roundT1)
        XCTAssertEqual(sut.roundT1, 1, "Score computed is wrong")
    }
    
    func testRoundIsComputedSub1() {
        sut.roundT1 = sut.sum1(round: sut.roundT1)
        sut.roundT1 = sut.sub1(round: sut.roundT1)
        XCTAssertEqual(sut.roundT1, 0, "Score computed is wrong")
    }
    
    func testRoundSub1NotNegative() {
        for _ in 0...5 {
            sut.roundT1 = sut.sub1(round: sut.roundT1)
            sut.roundT2 = sut.sub1(round: sut.roundT2)
        }
        
        XCTAssertEqual(sut.roundT1, 0, "Score computed is wrong")
        XCTAssertEqual(sut.roundT2, 0, "Score computed is wrong")
    }
    
    func testRoundIsReseted() {
        for _ in 0...10 {
            sut.roundT1 = sut.sum3(round: sut.roundT1)
            sut.roundT2 = sut.sum3(round: sut.roundT2)
        }
        
        sut.resetRound()
        XCTAssertEqual(sut.roundT1, 0, "Score computed is wrong")
        XCTAssertEqual(sut.roundT2, 0, "Score computed is wrong")
    }
    
    func testGameIsReseted() {
        for _ in 0...10 {
            sut.roundT1 = sut.sum3(round: sut.roundT1)
            sut.roundT2 = sut.sum3(round: sut.roundT2)
        }
        
        sut.resetRoundAndGame()
        XCTAssertEqual(sut.roundT1, 0, "Score computed is wrong")
        XCTAssertEqual(sut.roundT2, 0, "Score computed is wrong")
        XCTAssertEqual(sut.gameT1, 0, "Score computed is wrong")
        XCTAssertEqual(sut.gameT2, 0, "Score computed is wrong")
    }
}
