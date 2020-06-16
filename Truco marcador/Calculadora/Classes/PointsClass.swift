//
//  PointsClass.swift
//  Truco Marcador
//
//  Created by Joao Flores on 01/12/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit

class PointsClass {

//    public private (set) var roundT1: Int = 0
    var roundT1: Int = 0
    var gameT1: Int = 0
    var roundT2: Int = 0
    var gameT2: Int = 0

    func initGame() {
        self.roundT1 = 0
        self.gameT1 = 0
        self.roundT2 = 0
        self.gameT2 = 0
    }
    
    init() {
        initGame()
    }

    func sum3(round: Int) -> Int {

        let roundNew = round + 3
        return roundNew
    }

    func sum1(round: Int) -> Int{
        let roundNew = round + 1
        return roundNew
    }

    func sub1(round: Int) -> Int{
        if(round > 0) {
            let roundNew = round - 1
            return roundNew
        }
        else {
            return round
        }
    }

    func round1Sum3() {
        self.roundT1 = self.roundT1 + 3
    }
    
    func resetRoundAndGame() {
        self.gameT1 = 0
        self.gameT2 = 0
        resetRound()
    }

    func resetRound() {
        self.roundT1 = 0
        self.roundT2 = 0
    }

    func checkEndGame() -> Bool {
        if(roundT2 >= UserDefaults.standard.integer(forKey: "maxPoints") || roundT1 >= UserDefaults.standard.integer(forKey: "maxPoints")) {
            return true
        }
        return false
    }
    
    func finshScoreboard() -> Int{
        var winner = 2
        
        if(self.roundT1 >= UserDefaults.standard.integer(forKey: "maxPoints")) {
            self.roundT1 = UserDefaults.standard.integer(forKey: "maxPoints")
            winner = 1
        } else {
            self.roundT2 = UserDefaults.standard.integer(forKey: "maxPoints")
        }
        
        return winner
    }
    
    
}
