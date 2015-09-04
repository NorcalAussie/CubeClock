//
//  CCTime.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/12/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import Foundation

class CCTime: NSObject, NSCoding {
    var time: NSTimeInterval = 0.0
    var timeString: String = ""
    
    init (elapsedTime: NSTimeInterval) {
        self.time = elapsedTime
        self.timeString = convertTimeToFormattedString(elapsedTime)
    }
    
    override init() {
       super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(time, forKey: "time")
        aCoder.encodeObject(timeString, forKey: "timeString")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        time = aDecoder.decodeDoubleForKey("time")
        timeString = aDecoder.decodeObjectForKey("timeString") as! String
    }
}

func convertTimeToFormattedString(elapsedTime: NSTimeInterval) -> String {
    var theString = ""
    
    var elapsedTimeTemp = elapsedTime
    let minutes = UInt8(elapsedTimeTemp / 60.0)
    elapsedTimeTemp -= (NSTimeInterval(minutes) * 60)
    
    let seconds = UInt8(elapsedTimeTemp)
    elapsedTimeTemp -= NSTimeInterval(seconds)
    
    let fraction = UInt8(elapsedTimeTemp * 100)
    
    let strMinutes = String(format: "%02d", arguments: [minutes])
    let strSeconds = String(format: "%02d", arguments: [seconds])
    let strFraction = String(format: "%02d", arguments: [fraction])
    
    theString = "\(strMinutes):\(strSeconds):\(strFraction)"
    
    return theString
}
