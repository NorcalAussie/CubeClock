//
//  CCTimerViewController.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/7/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import UIKit

class CCTimerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var timesTableView: UITableView!
    
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var averageFiveLabel: UILabel!
    @IBOutlet weak var averageTenLabel: UILabel!
    @IBOutlet weak var threeOfFiveLabel: UILabel!
    @IBOutlet weak var tenOfTwelveLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    
    var timerRunning = false
    var needsReset = false
    
    var totalTime = 0.0
    
    var startTime = NSTimeInterval()
    
    var timer: NSTimer?
    var nextIndex = 0
    var timesArray: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        

    }
    
    @IBAction func clearPressed(sender: AnyObject) {
        timesArray.removeAll(keepCapacity: false)
        averageLabel.text = "-"
        bestLabel.text = "-"
        averageFiveLabel.text = "-"
        averageTenLabel.text = "-"
        threeOfFiveLabel.text = "-"
        tenOfTwelveLabel.text = "-"
        timerLabel.text = "00:00:00"
        needsReset = false
        timesTableView.reloadData()
        nextIndex = 0
        
    }
    
    @IBAction func tapDetected(sender: AnyObject) {
        if(!timerRunning){
            if(needsReset){
                timerLabel.text = "00:00:00"
                needsReset = false
            }
            
        }else{
            NSLog("stopping")
            stopTimer()
            recordTime()
            updateStats()
            
        }
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(!needsReset){
            if(!timerRunning){
                NSLog("touchesBegan")
                timerLabel.textColor = UIColor.redColor()
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(!needsReset){
            if(!timerRunning){
                let aSelector : Selector = "updateTime"
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
                timerLabel.textColor = UIColor.blackColor()
                timerRunning = true
                needsReset = true
                
            }
        }
    }
    
    func stopTimer(){
        timer!.invalidate()
        timer = nil
        timerRunning = false
        
    }
    
    func recordTime(){
        timesArray.insert(totalTime, atIndex: nextIndex)
        nextIndex++
        self.timesTableView.reloadData()
        
    }
    
    func updateTime(){
        
        if(timerRunning){
            
            var currentTime = NSDate.timeIntervalSinceReferenceDate()
            var elapsedTime: NSTimeInterval = currentTime - startTime
            
            timerLabel.text = convertTimeToFormattedString(elapsedTime)
            self.totalTime = Double(elapsedTime)
        }
        
    }
    
    func updateStats(){
        if(!timesArray.isEmpty) {
            averageLabel.text = convertTimeToFormattedString(calcAverages().average)
            bestLabel.text = convertTimeToFormattedString(calcAverages().bestTime)
            if (timesArray.count >= 5) {
                averageFiveLabel.text = convertTimeToFormattedString(calcAverages().averageFive)
                threeOfFiveLabel.text = convertTimeToFormattedString(calcOfAverage(5))
            }else{
                averageFiveLabel.text = "-"
                threeOfFiveLabel.text = "-"
            }
            if (timesArray.count >= 10) {
                averageTenLabel.text = convertTimeToFormattedString(calcAverages().averageTen)
            }
            else{
                averageTenLabel.text = "-"
            }
            if (timesArray.count >= 12) {
                tenOfTwelveLabel.text = convertTimeToFormattedString(calcOfAverage(12))
            }else{
                tenOfTwelveLabel.text = "-"
            }
        }else{
            clearPressed(self)
        }
        
    }
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.timesTableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light",
            size: 17.0)
        cell.textLabel?.text = String(format: "%d. %@", (self.timesArray.count - indexPath.row), convertTimeToFormattedString(self.timesArray[(self.timesArray.count - indexPath.row - 1)]))
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        timesArray.removeAtIndex((self.timesArray.count - (indexPath.row + 1)))
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        nextIndex--
        updateStats()
        tableView.reloadData()
    }

}
