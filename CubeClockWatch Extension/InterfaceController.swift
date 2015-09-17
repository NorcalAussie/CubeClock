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
    
    @IBOutlet var timer: WKInterfaceTimer!
    let states = ["ready": 1, "countdown": 2, "running": 3, "stopped": 4]
    var currentState: Int!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        currentState = states["ready"]

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
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }
        
        let message = ["key" : "word"]
        WCSession.defaultSession().sendMessage(message, replyHandler: { (_: [String : AnyObject]) -> Void in
           
            }) { (NSError) -> Void in
                
            }
        let futureDate = NSDate(timeInterval: 5, sinceDate: NSDate.init())
        timer.setDate(futureDate)
        timer.start()
    }
}
    

