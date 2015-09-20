//
//  CCTimerViewController.swift
//  CubeClock
//
//  Created by Matt Pearce on 8/7/15.
//  Copyright (c) 2015 MPApps. All rights reserved.
//

import UIKit
import WatchConnectivity

class CCTimerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WCSessionDelegate {
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
    
    @IBOutlet weak var themeSwitch: UISwitch!
    
    @IBOutlet weak var clearButton: UIButton!
    
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
    var path = String()
    
    //TimesArray and Time Objects created
    let timesArray = CCTimeArray()
    var allTimes: NSMutableArray = []
    var time: CCTime!
    
    // MARK: - Device Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //Get the path for saving
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("CubeClock.archive")
        path = fileURL.path!
        
        //If data is found, load it
        if (NSKeyedUnarchiver.unarchiveObjectWithFile(path) != nil) {
            timesArray.theArray = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSArray as! [CCTime]
            updateStats()
            nextIndex = timesArray.theArray.count
            timesTableView.reloadData()
        }
        
        if #available(iOS 9.0, *) {
            if (WCSession.isSupported()) {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
            }
        }
        
        themeSwitch.thumbTintColor = UIColor.blackColor()
        themeSwitch.tintColor = UIColor.blackColor()
        hintLabel.text = "Tap to begin 5 second countdown"
        themeSwitch.setOn(false, animated: false)
        updateStats()
        getNewScramble()

    }
    
    // MARK: - Local Functions
    func updateTime() {
        if (timerRunning) {
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = currentTime - startTime
            
            self.time = CCTime(elapsedTime: elapsedTime)
            timerLabel.text = time.timeString
        }
    }
    
    func recordTime() {
        timesArray.theArray.insert(time, atIndex: nextIndex)
        nextIndex++
        saveData()
        
        self.timesTableView.reloadData()
    }
    
    func stopTimer() {
        timer!.invalidate()
        timer = nil
        hintLabel.text = "Tap to reset timer"
        timerRunning = false
        primed = false
        clearButton.enabled = true
        
        if #available(iOS 9.0, *) {
            sendRecentTimesToWatch()
        }
    }
    
    func saveData() {
        //Archive array
        if NSKeyedArchiver.archiveRootObject(timesArray.theArray, toFile: path) {
            
        } else {
            print("Unable to write to file!")
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
            clearData()
        }
    }
    
    private func clearData() {
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
    
    func beginCountdown() {
        hintLabel.text = ""
        timerLabel.text = "5"
        primed = false
        clearButton.enabled = false
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countDown:"), userInfo: nil, repeats: true)
    }
    
    func countDown(time: NSTimer) {
        if (countdown == 0) {
            time.invalidate()
            countdown = 4
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
            timerRunning = true
            needsReset = true
            primed = false
        } else {
            timerLabel.text = String(format: "%i", arguments: [countdown])
            countdown = countdown - 1
        }
    }
    
    func watchButtonPressed() {
        dispatch_async(dispatch_get_main_queue(), {
            // UI Updating code here.
            self.tapDetected(self)
            });
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
            alert.message = "To use the timer, tap the screen to begin a 5 second timer, the timer will start at the end of the countdown. To stop the timer simply tap the screen again. Tap once more to reset when you finish and a new scramble will also be generated and displayed for you\n\n Version: 1.2"
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
                    clearButton.enabled = true
                    timerLabel.text = "00:00:00"
                    primed = true
                    hintLabel.text = "Tap to begin 5 second countdown"
                }
            } else if (primed) {
                NSLog("not running, primed")
                beginCountdown()
            }
        } else {
            stopTimer()
            recordTime()
            updateStats()
        }
    }
    
    @IBAction func themeSwitched(sender: AnyObject) {
        if (themeSwitch.on) {
            //When on switch to dark theme
            self.view.backgroundColor = UIColor.blackColor()
            
            timesTableView.backgroundColor = UIColor.blackColor()
            
            clearButton.backgroundColor = UIColor.blackColor()
            
            timerLabel.textColor = UIColor.whiteColor()
            averageLabel.textColor = UIColor.whiteColor()
            averageTenLabel.textColor = UIColor.whiteColor()
            averageFiveLabel.textColor = UIColor.whiteColor()
            bestLabel.textColor = UIColor.whiteColor()
            threeOfFiveLabel.textColor = UIColor.whiteColor()
            tenOfTwelveLabel.textColor = UIColor.whiteColor()
            
            themeSwitch.thumbTintColor = UIColor.blackColor()
            themeSwitch.onTintColor = UIColor.whiteColor()
            
            timesTableView.reloadData()
        } else {
            //Light theme
            self.view.backgroundColor = UIColor.whiteColor()
            
            timesTableView.backgroundColor = UIColor.whiteColor()
            
            clearButton.backgroundColor = UIColor.whiteColor()
            
            timerLabel.textColor = UIColor.blackColor()
            averageLabel.textColor = UIColor.blackColor()
            averageTenLabel.textColor = UIColor.blackColor()
            averageFiveLabel.textColor = UIColor.blackColor()
            bestLabel.textColor = UIColor.blackColor()
            threeOfFiveLabel.textColor = UIColor.blackColor()
            tenOfTwelveLabel.textColor = UIColor.blackColor()
            
            themeSwitch.thumbTintColor = UIColor.blackColor()
            themeSwitch.tintColor = UIColor.blackColor()
            
            timesTableView.reloadData()
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
        if (themeSwitch.on) {
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.blackColor()
        } else {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = UIColor.whiteColor()
        }
        
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
        saveData()
        tableView.reloadData()
    }
    
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSLog("Message from watch recieved : %@,", message)
        watchButtonPressed()
    }
    
    @available(iOS 9.0, *)
    func sendRecentTimesToWatch() {
        let message = ["first": "00:00:00", "second": "00:30:23", "third": "00:23:41"]
        WCSession.defaultSession().sendMessage(message, replyHandler: { (_: [String : AnyObject]) -> Void in
            
            }) { (NSError) -> Void in
                
        }
    }

}
