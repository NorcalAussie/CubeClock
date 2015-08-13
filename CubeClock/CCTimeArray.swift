//
//  CCTimeArray.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/12/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import Foundation

class CCTimeArray{
    var timesArray: [Double] = []
    
    func calcOfAverage(totalTrials: Int) -> Double{
        var avg = 0.0
        var tempIndex = 1
        var tempArrayIndex = 0
        var tempArray: [Double] = []
        
        //Put last 5 or 12 times into a new array
        for times in timesArray {
            if (timesArray.count - tempIndex < totalTrials) {
                tempArray.insert(times, atIndex: tempArrayIndex)
                tempArrayIndex++
            }
            
            tempIndex++
        }
        
        //Sort array and calculate average using all but first and last element
        tempArray.sort(>)
        var sum = 0.0
        tempIndex = 1
        for time in tempArray {
            if (tempIndex != 1 && tempIndex < tempArray.count) {
                sum += time
            }
            
            tempIndex++
        }
        
        avg = sum/Double((totalTrials - 2))
        
        return avg
    }
    
    func calcAverages() -> (average: Double, averageFive: Double, averageTen: Double, bestTime: Double){
        var sum = 0.0
        var lastFiveSum = 0.0
        var lastTenSum = 0.0
        var bestTime = timesArray[0]
        var tempIndex = 1
        
        for times in timesArray {
            sum += times
            
            if (timesArray.count >= 5) && (timesArray.count - tempIndex < 5){
                lastFiveSum += times
            }
            
            if (timesArray.count >= 10) && (timesArray.count - tempIndex < 10){
                lastTenSum += times
            }
            
            if times < bestTime{
                bestTime = times
            }
            
            tempIndex++
        }
        
        var avg: Double = sum/Double((timesArray.count))
        var avgFive: Double = lastFiveSum/5.0
        var avgTen: Double = lastTenSum/10.0
        
        return (avg, avgFive, avgTen, bestTime)
    }
}

