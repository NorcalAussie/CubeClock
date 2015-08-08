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
    
    var startTime = NSTimeInterval()
    
    var timer: NSTimer?
    var nextIndex = 0
    var timesArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    @IBAction func tapDetected(sender: AnyObject) {
        if(!timerRunning){
            timerLabel.text = "00:00:00"
            
        }else{
            NSLog("stopping")
            stopTimer()
            recordTime()
            
        }
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(!timerRunning){
            NSLog("touchesBegan")
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(!timerRunning){
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
            timerRunning = true
            
        }
    }
    
    func stopTimer(){
        timer!.invalidate()
        timer = nil
        timerRunning = false
        
    }
    
    func recordTime(){
        
        timesArray.insert(timerLabel.text!, atIndex: nextIndex)
        nextIndex++
        self.timesTableView.reloadData()
        
    }
    
    func updateTime(){
        
        if(timerRunning){
            var currentTime = NSDate.timeIntervalSinceReferenceDate()
            var elapsedTime: NSTimeInterval = currentTime - startTime
            
            let minutes = UInt8(elapsedTime / 60.0)
            elapsedTime -= (NSTimeInterval(minutes) * 60)
            
            let seconds = UInt8(elapsedTime)
            elapsedTime -= NSTimeInterval(seconds)
            
            let fraction = UInt8(elapsedTime * 100)
            
            let strMinutes = String(format: "%02d", arguments: [minutes])
            let strSeconds = String(format: "%02d", arguments: [seconds])
            let strFraction = String(format: "%02d", arguments: [fraction])
            
            timerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.timesTableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = self.timesArray[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
