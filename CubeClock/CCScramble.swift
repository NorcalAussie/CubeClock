//
//  CCScramble.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/13/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import Foundation

class CCScramble: NSObject {
    var scrambleString:String!
    var scramble:NSArray!
    
    override init(){
        self.scramble = generateScramble()
        self.scrambleString = getScrambleString(self.scramble)
    }

}

func generateScramble() -> NSArray {
    let possibleTurns = ["R", "L", "D", "F", "B", "R'", "L'", "D'", "F'", "B'", "R2", "L2", "D2", "F2", "B2"]
    var previousMove = " "
    var nextMove = ""
    var randomIndex = 0
    var moves: [String] = []
    
    for var index = 0; index < 25; ++index {
        do {
            randomIndex = Int(arc4random_uniform(15))
            nextMove = possibleTurns[randomIndex]
        }
            while (Array(nextMove)[0] == Array(previousMove)[0])
        
        previousMove = nextMove
        moves.insert(nextMove, atIndex: index)
    }
    
    return moves
}

func getScrambleString(scramble: NSArray) -> String {
    var theString = ""
    
    for move in scramble {
        theString += "\(move) "
    }
    
    return theString
}
