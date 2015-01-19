//
//  RouteTableViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/18/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class RouteTableContainer: UIViewController {
    // Logger
    let logger = Swell.getLogger("RouteTableContainer")
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func exitTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class RouteTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Logger
    let logger = Swell.getLogger("RouteTableViewController")
    
    // Datasource variables
    var groupNames = [String]()
    var routeNames = [[String]]()
    var sessionCounts = [[Int]]()
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //UINavigationControllerHideShowBarDuration
        navigationController?.setNavigationBarHidden(true, animated: false)
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
            var tempSessionCounts = [Int]()
            
            // Enumerate the objects in our NSOrderedSet and save the route names
            routes.enumerateObjectsUsingBlock { (route, index, stop) -> Void in
                tempRouteNames.append(route.name)
                tempSessionCounts.append(routes.count)
            }
            
            routeNames.append(tempRouteNames)
            sessionCounts.append(tempSessionCounts)
        }
        
        logger.debug("Data source populated")
    }
    
    // MARK: - UITableViewController overrides
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupNames.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeNames[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupNames[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // This will be the case for programmatically loaded cells (see viewDidLoad to switch approaches)
        if let cell = tableView.dequeueReusableCellWithIdentifier(Const.Cell.Route) as? UITableViewCell {
            cell.textLabel!.text = "\(routeNames[indexPath.section][indexPath.row]) - \(sessionCounts[indexPath.section][indexPath.row])"
            // Configure the cell for this indexPath
            //            cell.updateFonts()
            //            let modelItem = model.dataArray[indexPath.row]
            //            cell.titleLabel.text = modelItem.title
            //            cell.bodyLabel.text = modelItem.body
            //
            //            // Make sure the constraints have been added to this cell, since it may have just been created from scratch
            //            cell.setNeedsUpdateConstraints()
            //            cell.updateConstraintsIfNeeded()
            
            return cell
        }
        
        //        // This will be the case for interface builder loaded cells (see viewDidLoad to switch approaches)
        //        if let cell: NibTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as? NibTableViewCell {
        //            // Configure the cell for this indexPath
        //            cell.updateFonts()
        //            let modelItem = model.dataArray[indexPath.row]
        //            cell.titleLabel.text = modelItem.title
        //            cell.bodyLabel.text = modelItem.body
        //
        //            // Make sure the constraints have been added to this cell, since it may have just been created from scratch
        //            cell.setNeedsUpdateConstraints()
        //            cell.updateConstraintsIfNeeded()
        //            
        //            return cell
        //        }
        
        logger.error("Did not recognize reusable cell")
        return UITableViewCell();
    }
}

class SessionTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Logger
    let logger = Swell.getLogger("SessionTableViewController")
    
    // Datasource variables
    var sessionNames = [String]()
    var sessionDistances = [[Double]]()
    var sessionTimes = [NSDate]()
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        populateDataSource()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - CoreData accessors
    
//    // Populate UITableView data source
//    func populateDataSource() {
//        // Load all groups and their associated routes
//        let groups = getObjects(Const.Data.Group, nil) as [Group]
//        
//        for group in groups {
//            // Populate the section headers
//            groupNames.append(group.name)
//            
//            let routes = group.routes
//            var tempRouteNames = [String]()
//            var tempSessionCounts = [Int]()
//            
//            // Enumerate the objects in our NSOrderedSet and save the route names
//            routes.enumerateObjectsUsingBlock { (route, index, stop) -> Void in
//                tempRouteNames.append(route.name)
//                tempSessionCounts.append(routes.count)
//            }
//            
//            routeNames.append(tempRouteNames)
//            sessionCounts.append(tempSessionCounts)
//        }
//        
//        logger.debug("Data source populated")
//    }
//    
//    // MARK: - UITableViewController overrides
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return groupNames.count
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return routeNames[section].count
//    }
//    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return groupNames[section]
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        // This will be the case for programmatically loaded cells (see viewDidLoad to switch approaches)
//        if let cell = tableView.dequeueReusableCellWithIdentifier(Const.Cell.Route) as? UITableViewCell {
//            cell.textLabel!.text = "\(routeNames[indexPath.section][indexPath.row]) - \(sessionCounts[indexPath.section][indexPath.row])"
//            // Configure the cell for this indexPath
//            //            cell.updateFonts()
//            //            let modelItem = model.dataArray[indexPath.row]
//            //            cell.titleLabel.text = modelItem.title
//            //            cell.bodyLabel.text = modelItem.body
//            //
//            //            // Make sure the constraints have been added to this cell, since it may have just been created from scratch
//            //            cell.setNeedsUpdateConstraints()
//            //            cell.updateConstraintsIfNeeded()
//            
//            return cell
//        }
//        
//        //        // This will be the case for interface builder loaded cells (see viewDidLoad to switch approaches)
//        //        if let cell: NibTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as? NibTableViewCell {
//        //            // Configure the cell for this indexPath
//        //            cell.updateFonts()
//        //            let modelItem = model.dataArray[indexPath.row]
//        //            cell.titleLabel.text = modelItem.title
//        //            cell.bodyLabel.text = modelItem.body
//        //
//        //            // Make sure the constraints have been added to this cell, since it may have just been created from scratch
//        //            cell.setNeedsUpdateConstraints()
//        //            cell.updateConstraintsIfNeeded()
//        //            
//        //            return cell
//        //        }
//        
//        logger.error("Did not recognize reusable cell")
//        return UITableViewCell();
//    }
}
