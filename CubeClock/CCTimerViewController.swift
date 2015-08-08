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
        
        cell.textLabel?.text = convertTimeToFormattedString(self.timesArray[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
