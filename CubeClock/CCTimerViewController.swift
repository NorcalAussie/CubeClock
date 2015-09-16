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
    @IBOutlet weak var scrambleLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!
    
    //Table View Outlet
    @IBOutlet weak var timesTableView: UITableView!
    
    // MARK: - Local Variables
    var timerRunning = false
    var needsReset = false
    var totalTime = 0.0
    var startTime = NSTimeInterval()
    var timer: NSTimer?
    var countdownTimer: NSTimer?
    var nextIndex = 0
    var primed = true
    var countdown: Int! = 4
    
    //TimesArray and Time Objects created
    let timesArray = CCTimeArray()
    var allTimes:NSMutableArray = []
    var time:CCTime!
    
    var path = String()
    
    // MARK: - Device Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("CubeClock.archive")
        
        path = fileURL.path!
        
        if (NSKeyedUnarchiver.unarchiveObjectWithFile(path) != nil) {
            timesArray.theArray = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSArray as! [CCTime]
            updateStats()
            nextIndex = timesArray.theArray.count
            timesTableView.reloadData()
        }
        
        //timesArray.theArray = [CCTime(elapsedTime: 65.542),CCTime(elapsedTime: 61.934),CCTime(elapsedTime: 57.1236),CCTime(elapsedTime: 71.6213412),CCTime(elapsedTime: 62.2178362),CCTime(elapsedTime: 59.9127309)]
        updateStats()
        //timerLabel.text = CCTime(elapsedTime: 31.23423).timeString
        hintLabel.text = "Tap to begin 5 second countdown"
        
        getNewScramble()
    }

    // MARK: - Local Functions
    func stopTimer() {
        timer!.invalidate()
        timer = nil
        hintLabel.text = "Tap to reset timer"
        timerRunning = false
        primed = false
        clearButton.enabled = true
    }
    
    func recordTime() {
        NSLog("\(time.time)")
        timesArray.theArray.insert(time, atIndex: nextIndex)
        nextIndex++
        saveData()
        
        self.timesTableView.reloadData()
    }
    
    func updateTime() {
        if (timerRunning) {
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = currentTime - startTime
            
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
            
        } else {
            print("Unable to write to file!")
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
        primed = true
        timesTableView.reloadData()
        nextIndex = 0
        hintLabel.text = "Tap to begin 5 second countdown"
        getNewScramble()
    }
    
    func getNewScramble() {
        //Generate Scrable and display
        let scramble = CCScramble()
        scrambleLabel.text = scramble.scrambleString
    }
    
    
    // MARK: - IBActions
    @IBAction func clearPressed(sender: AnyObject) {
        if (!timesArray.theArray.isEmpty) {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Clear", style: .Default, handler: { (alertAction) -> Void in
                    self.clearData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func infoPressed(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "Help", message: nil, preferredStyle: .Alert)
            alert.message = "To use the timer, tap the screen to begin a 5 second timer, the timer will start at the end of the countdown. To stop the timer simply tap the screen again. Tap once more to reset when you finish and a new scramble will also be generated and displayed for you\n\n Version: 1.1"
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func tapDetected(sender: AnyObject) {
        if (!timerRunning) {
            if (!primed) {
                if (needsReset) {
                    timerLabel.text = "00:00:00"
                    needsReset = false
                    primed = true
                    hintLabel.text = "Tap to begin 5 second countdown"
                    getNewScramble()
                } else if (!needsReset) {
                    countdownTimer?.invalidate()
                    countdown = 4
                    timerLabel.text = "00:00:00"
                    primed = true
                    hintLabel.text = "Tap to begin 5 second countdown"
                }
            } else if (primed) {
                NSLog("not running, primed")
                hintLabel.text = ""
                timerLabel.text = "5"
                primed = false
                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countDown:"), userInfo: nil, repeats: true)
                
            }
        } else {
            stopTimer()
            recordTime()
            updateStats()
        }
    }
    
    func countDown(time: NSTimer) {
        if (countdown == 0) {
            time.invalidate()
            countdown = 4
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
            timerLabel.textColor = UIColor.blackColor()
            clearButton.enabled = false
            timerRunning = true
            needsReset = true
            primed = false
        } else {
            timerLabel.text = String(format: "%i", arguments: [countdown])
            countdown = countdown - 1
        }
        
    }
    
    // MARK: - TableView  Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timesArray.theArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.timesTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.font = UIFont(name: "Avenir-LightOblique",
            size: 12.0)
        cell.textLabel?.text = String(format: "%d. %@", (self.timesArray.theArray.count - indexPath.row), timesArray.theArray[(timesArray.theArray.count - indexPath.row - 1)].timeString)
        cell.textLabel?.textAlignment = .Center
        
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
