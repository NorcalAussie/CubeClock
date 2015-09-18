//
//  InterfaceController.swift
//  CubeClockWatch Extension
//
//  Created by Matt Pearce on 9/16/15.
//  Copyright © 2015 MPApps. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var countdownLabel: WKInterfaceLabel!
    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    
    let states = ["ready": 1, "countdown": 2, "running": 3, "stopped": 4]
    var currentState: Int!
    var countdown: Int = 4
    var countdownTimer: NSTimer?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        currentState = states["ready"]
        countdownLabel.setHidden(true)

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func buttonPressed() {
        
        switch currentState {
        case 1:
            countdownLabel.setHidden(false)
            countdownLabel.setText("5")
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countDown:"), userInfo: nil, repeats: true)
            button.setTitle("Countdown")
            
            currentState = 2
            break
        case 2:
            countdownTimer?.invalidate()
            countdown = 4
            countdownLabel.setText("5")
            countdownLabel.setHidden(true)
            currentState = 1
            break
        case 3:
            button.setTitle("Stopped")
            timer.stop()
            currentState = 4
            break
        case 4:
            button.setTitle("Start")
            timer.setDate(NSDate())
            timer.stop()
            currentState = 1
            break
        default:
            break
        }
        
        let message = ["key" : "word"]
        WCSession.defaultSession().sendMessage(message, replyHandler: { (_: [String : AnyObject]) -> Void in
           
            }) { (NSError) -> Void in
                
            }
    }
    
    func countDown(time: NSTimer) {
        if (countdown == 0) {
            timer.setDate(NSDate(timeInterval: 0, sinceDate: NSDate.init(timeIntervalSinceNow: -0.5)))
            timer.start()
            countdownTimer?.invalidate()
            countdown = 4
            countdownLabel.setHidden(true)
            button.setEnabled(true)
            button.setTitle("Running")
            currentState = 3
        } else {
            countdownLabel.setText(String(format: "%i", arguments: [countdown]))
            countdown--
        }
    }
}


