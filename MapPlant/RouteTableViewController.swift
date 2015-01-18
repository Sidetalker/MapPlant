//
//  RouteTableViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/18/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class RouteTableContainer: UIViewController {
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    
    @IBAction func exitTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class RouteTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Datasource variables
    var groupNames = [String]()
    var routeNames = [[String]]()
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateDataSource()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - CoreData accessors
    
    // Populate UITableView data source
    func populateDataSource() {
        // Load all groups and their associated routes
        let groups = getObjects(Const.Data.Group, nil) as [Group]
        
        for group in groups {
            // Populate the section headers
            groupNames.append(group.name)
            
            let routes = group.routes
            var tempRouteNames = [String]()
            
            // Enumerate the objects in our NSOrderedSet and save the route names
            routes.enumerateObjectsUsingBlock { (route, index, stop) -> Void in
                tempRouteNames.append(route.name)
            }
            
            routeNames.append(tempRouteNames)
        }
    }
    
    
}
