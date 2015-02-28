//
//  RouteViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 2/28/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {
    // Datasource variables
    var groupIndex = -1
    var routeIndex = -1
    
    // IBOutlets
    @IBOutlet weak var containerSessions: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass necessary information down the change to the Sessions TVC
        if segue.identifier == Const.Segue.SessionsTable {
            let sessionTVC = segue.destinationViewController as SessionTableViewController
            
            sessionTVC.groupIndex = groupIndex
            sessionTVC.routeIndex = routeIndex
        }
    }
}