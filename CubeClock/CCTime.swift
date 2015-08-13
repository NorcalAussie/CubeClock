//
//  CCTime.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/12/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import Foundation

class CCTime {
    var time: Double = 0.0
    var timeString: String = ""
    
    init (elapsedTime: Double){
        self.time = elapsedTime
        self.timeString = convertTimeToFormattedString(elapsedTime)
        
    }
    
}



func convertTimeToFormattedString(elapsedTime: Double) -> String {
    var theString = ""
    
    var elapsedTimeTemp = elapsedTime
    
    let minutes = UInt8(elapsedTime / 60.0)
    elapsedTimeTemp -= (NSTimeInterval(minutes) * 60)
    
    let seconds = UInt8(elapsedTime)
    elapsedTimeTemp -= NSTimeInterval(seconds)
    
    let fraction = UInt8(elapsedTimeTemp * 100)
    
    let strMinutes = String(format: "%02d", arguments: [minutes])
    let strSeconds = String(format: "%02d", arguments: [seconds])
    let strFraction = String(format: "%02d", arguments: [fraction])
    
    theString = "\(strMinutes):\(strSeconds):\(strFraction)"
    
    return theString
    
}
