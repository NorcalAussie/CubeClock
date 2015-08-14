//
//  CCTimerViewController.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/7/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import UIKit

class CCTimerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var averageFiveLabel: UILabel!
    @IBOutlet weak var averageTenLabel: UILabel!
    @IBOutlet weak var threeOfFiveLabel: UILabel!
    @IBOutlet weak var tenOfTwelveLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    
    //Table View Outlet
    @IBOutlet weak var timesTableView: UITableView!
    
    // MARK: - Local Variables
    var timerRunning = false
    var needsReset = false
    var totalTime = 0.0
    var startTime = NSTimeInterval()
    var timer: NSTimer?
    var nextIndex = 0
    
    //TimesArray and Time Objects created
    let timesArray = CCTimeArray()
    var allTimes:NSMutableArray = []
    var time:CCTime!
    
    var documentDirectories:NSArray!
    var documentDirectory:String!
    var path:String!
    
    // MARK: - Device Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Create a filepath for archiving.
        documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        // Get document directory from that list
        documentDirectory = documentDirectories.objectAtIndex(0) as! String
        
        // append with the .archive file name
        path = documentDirectory.stringByAppendingPathComponent("CubeClock.archive")
        
        if (NSKeyedUnarchiver.unarchiveObjectWithFile(path) != nil) {
            timesArray.theArray = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSArray as! [CCTime]
            updateStats()
            nextIndex = timesArray.theArray.count
            timesTableView.reloadData()
        }
    }

    // MARK: - Local Functions
    func stopTimer() {
        timer!.invalidate()
        timer = nil
        timerRunning = false
    }
    
    func recordTime() {
        timesArray.theArray.insert(time, atIndex: nextIndex)
        nextIndex++
        saveData()
        
        self.timesTableView.reloadData()
    }
    
    func updateTime(){
        if (timerRunning) {
            var currentTime = NSDate.timeIntervalSinceReferenceDate()
            var elapsedTime: NSTimeInterval = currentTime - startTime
            
            self.time = CCTime(elapsedTime: elapsedTime)
            timerLabel.text = time.timeString
        }
    }
    
    func updateStats(){
        if (!timesArray.theArray.isEmpty) {
            averageLabel.text = timesArray.calcAverages().average.timeString
            bestLabel.text = timesArray.calcAverages().bestTime.timeString
            if (timesArray.theArray.count >= 5) {
                averageFiveLabel.text = timesArray.calcAverages().averageFive.timeString
                threeOfFiveLabel.text = timesArray.calcOfAverage(5).timeString
            } else {
                averageFiveLabel.text = "-"
                threeOfFiveLabel.text = "-"
            }
            if (timesArray.theArray.count >= 10) {
                averageTenLabel.text = timesArray.calcAverages().averageTen.timeString
            } else {
                averageTenLabel.text = "-"
            }
            if (timesArray.theArray.count >= 12) {
                tenOfTwelveLabel.text = timesArray.calcOfAverage(12).timeString
            } else {
                tenOfTwelveLabel.text = "-"
            }
        } else {
            clearPressed(self)
        }
    }
    
    func saveData() {
        //Archive array
        if NSKeyedArchiver.archiveRootObject(timesArray.theArray, toFile: path) {
            println("Success writing to file!")
        } else {
            println("Unable to write to file!")
        }
    }
    
    func clearData() {
        timesArray.theArray.removeAll(keepCapacity: false)
        allTimes.removeAllObjects()
        saveData()
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
    
    
    // MARK: - IBActions
    @IBAction func clearPressed(sender: AnyObject) {
        if (!timesArray.theArray.isEmpty) {
            let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Clear", style: .Default, handler: { (alertAction) -> Void in
                self.clearData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapDetected(sender: AnyObject) {
        if (!timerRunning) {
            if (needsReset) {
                timerLabel.text = "00:00:00"
                needsReset = false
            }
            
        } else {
            NSLog("stopping")
            stopTimer()
            recordTime()
            updateStats()
        }
    }
    
    // MARK: - Touch recognizers
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(!needsReset) {
            if(!timerRunning) {
                NSLog("touchesBegan")
                timerLabel.textColor = UIColor.redColor()
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(!needsReset) {
            if(!timerRunning) {
                let aSelector : Selector = "updateTime"
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
                timerLabel.textColor = UIColor.blackColor()
                timerRunning = true
                needsReset = true
            }
        }
    }
    
    // MARK: - TableView  Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timesArray.theArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.timesTableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light",
            size: 17.0)
        cell.textLabel?.text = String(format: "%d. %@", (self.timesArray.theArray.count - indexPath.row), timesArray.theArray[(timesArray.theArray.count - indexPath.row - 1)].timeString)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        timesArray.theArray.removeAtIndex((self.timesArray.theArray.count - (indexPath.row + 1)))
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        nextIndex--
        updateStats()
        tableView.reloadData()
    }
    
}
