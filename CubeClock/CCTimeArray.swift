//
//  CCTimeArray.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/12/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import Foundation

class CCTimeArray{
    var theArray: [CCTime] = []
    
    func calcOfAverage(totalTrials: Int) -> CCTime{
        var avg = 0.0
        var tempIndex = 1
        var tempArrayIndex = 0
        var tempArray: [CCTime] = []
        
        //Put last 5 or 12 times into a new array
        for times in theArray {
            if (theArray.count - tempIndex < totalTrials) {
                tempArray.insert(times, atIndex: tempArrayIndex)
                tempArrayIndex++
            }
            
            tempIndex++
        }
        
        //Sort array and calculate average using all but first and last element
        tempArray.sort({ $0.time > $1.time })
        var sum = 0.0
        tempIndex = 1
        for time in tempArray {
            if (tempIndex != 1 && tempIndex < tempArray.count) {
                sum += time.time
            }
            
            tempIndex++
        }
        
        avg = sum/Double((totalTrials - 2))
        let avgTime = CCTime(elapsedTime: avg)
        
        return avgTime
    }
    
    func calcAverages() -> (average: CCTime, averageFive: CCTime, averageTen: CCTime, bestTime: CCTime){
        var sum = 0.0
        var lastFiveSum = 0.0
        var lastTenSum = 0.0
        var best = theArray[0].time
        var tempIndex = 1
        
        for times in theArray {
            sum += times.time
            
            if (theArray.count >= 5) && (theArray.count - tempIndex < 5){
                lastFiveSum += times.time
            }
            
            if (theArray.count >= 10) && (theArray.count - tempIndex < 10){
                lastTenSum += times.time
            }
            
            if times.time < best{
                best = times.time
            }
            
            tempIndex++
        }
        
        let bestTime = CCTime(elapsedTime: best)
        
        var avg: Double = sum/Double((theArray.count))
        let avgTime = CCTime(elapsedTime: avg)
        
        var avgFive: Double = lastFiveSum/5.0
        let avgFiveTime = CCTime(elapsedTime: avg)
        
        var avgTen: Double = lastTenSum/10.0
        let avgTenTime = CCTime(elapsedTime: avg)
        
        return (avgTime, avgFiveTime, avgTenTime, bestTime)
    }
}

