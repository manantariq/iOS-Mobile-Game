//
//  Player.swift
//  MobileApp16
//
//  Created by Ilaria Carlini on 16/11/16.
//
//

import Foundation

class Player {
    var name: String
    var turn: Color
    var win: Int
    var draw: Int
    
    init(name: String, turn: Color, win: Int, draw: Int) {
        self.name = name
        self.turn = turn
        self.win = win
        self.draw = draw
    }
}
