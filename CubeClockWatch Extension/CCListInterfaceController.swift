//
//  CCListInterfaceController.swift
//  CubeClock
//
//  Created by Matt Pearce on 9/17/15.
//  Copyright © 2015 MPApps. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class CCListInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var table: WKInterfaceTable!

    var firstTime = ""
    var secondTime = ""
    var thirdTime = ""
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        table.setNumberOfRows(3, withRowType: "rowIdentifier")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateRows()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateRows() {
        var row: CCRow? = table.rowControllerAtIndex(0) as? CCRow
        row?.timeLabel.setText("firstTime")
        
        row = table.rowControllerAtIndex(1) as? CCRow
        row?.timeLabel.setText(secondTime)
        
        row = table.rowControllerAtIndex(2) as? CCRow
        row?.timeLabel.setText(thirdTime)
    }
    
    
    func session(session: WCSession, didReceiveMessage theMessage: [String : AnyObject]) {
        NSLog("Message from phone recieved : %@,", theMessage)

        firstTime = theMessage["first"] as! String
        secondTime = theMessage["second"] as! String
        thirdTime = theMessage["third"] as! String
        
        updateRows()
        
    }

}
