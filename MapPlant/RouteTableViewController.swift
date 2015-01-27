//
//  RouteTableViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/18/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

// MARK: - RouteTableContainer

class RouteTableContainer: UIViewController {
    // Logger
    let logger = Swell.getLogger("RouteTableContainer")
    
    // Other view references
    var routeTable: RouteTableViewController?
    var alertView: UIView?
    var groupTable: GroupTableViewController?
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Const.Segue.RoutesTable {
            routeTable = segue.destinationViewController as? RouteTableViewController
            routeTable?.state = 0
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func exitTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Presents valid editing options
    @IBAction func editTouchUp(sender: AnyObject) {
        let editController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.Alert)
        
        let addGroup = UIAlertAction(title: "Add Group", style: UIAlertActionStyle.Default)
            { (_) in self.addGroup() }
        let removeGroup = UIAlertAction(title: "Add Route", style: UIAlertActionStyle.Default)
            { (_) in self.addRoute() }
        let reorder = UIAlertAction(title: "Reorder", style: UIAlertActionStyle.Default)
            { (_) in self.reorder() }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (_) in }
        
        editController.addAction(addGroup)
        editController.addAction(removeGroup)
//        editController.addAction(reorder)
        editController.addAction(cancelAction)
        
        self.presentViewController(editController, animated: true) { (_) in
        }
    }
    
    // Handles user input for adding a new group
    func addGroup() {
        logger.debug("Adding a new group")
        
        let newGroupController = UIAlertController(title: "Add Group", message: "Enter the new group and route name", preferredStyle: UIAlertControllerStyle.Alert)
        
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.Default) { (_) in
            let groupTextField = newGroupController.textFields![0] as UITextField
            let routeTextField = newGroupController.textFields![1] as UITextField
            let groupName = groupTextField.text
            let routeName = routeTextField.text
            let existingGroups = getObjects(Const.Data.Group, nil) as [Group]
            let existingRoutes = getObjects(Const.Data.Route, nil) as [Route]
            
            // Don't allow blank group names
            if groupName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" ||
            routeName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""{
                self.logger.debug("Empty name not allowed")
                
                let notAllowedController = UIAlertController(title: "Error", message: "Names cannot be blank", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (_) in
                    self.presentViewController(newGroupController, animated: true, completion: nil)
                }
                
                notAllowedController.addAction(okButton)
                
                self.presentViewController(notAllowedController, animated: true) { (_) in }
                
                return
            }
            
            // Look throughout existing groups for a duplicate group name
            for group in existingGroups {
                if group.name == groupName {
                    self.logger.debug("Duplicate group name not allowed")
                    
                    let notAllowedController = UIAlertController(title: "Error", message: "Group name already exists", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (_) in
                        self.presentViewController(newGroupController, animated: true, completion: nil)
                    }
                    
                    notAllowedController.addAction(okButton)
                    
                    self.presentViewController(notAllowedController, animated: true) { (_) in }
                    
                    return
                }
            }
            
            self.logger.debug("Creating group: \(groupName) with route: \(routeName)")
            
            // Create our group
            let newGroup = insertObject(Const.Data.Group) as? Group
            newGroup!.name = groupName
            
            // Create a default route
            let newRoute = insertObject(Const.Data.Route) as? Route
            newRoute!.name = routeName
            newRoute!.group = newGroup!
            
            // Add the new route to the group's route list
            var mutableRoutes = newGroup!.routes.mutableCopy() as NSMutableOrderedSet
            mutableRoutes.addObject(newRoute!)
            newGroup!.routes = mutableRoutes.copy() as NSOrderedSet
            
            save()
            
            // Animate the addition of the new group
            self.routeTable!.tableView.beginUpdates()
            
            self.routeTable!.tableView.insertSections(NSIndexSet(index: self.routeTable!.groupNames.count), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.routeTable!.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: self.routeTable!.groupNames.count)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.routeTable!.populateDataSource()
            
            self.routeTable!.tableView.endUpdates()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (_) in
            self.logger.debug("Add group cancelled by user")
        }
        
        newGroupController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Group Name"
        }
        
        newGroupController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Route Name"
        }
        
        newGroupController.addAction(createAction)
        newGroupController.addAction(cancelAction)
        
        self.presentViewController(newGroupController, animated: true) { (_) in }
    }
    
    // Handles user input for adding a new route
    func addRoute() {
        logger.debug("Adding a new route")
        
        let newRouteController = UIAlertController(title: "Add Route", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.Default) { (_) in
            let routeTextField = newRouteController.textFields![0] as UITextField
            let routeName = routeTextField.text
            let existingRoutes = getObjects(Const.Data.Route, nil) as [Route]
            
            // Don't allow blank group names
            if routeName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                self.logger.debug("Add route empty name not allowed")
                
                let notAllowedController = UIAlertController(title: "Error", message: "Route name cannot be empty", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (_) in
                    self.presentViewController(newRouteController, animated: true, completion: nil)
                }
                
                notAllowedController.addAction(okButton)
                
                self.presentViewController(notAllowedController, animated: true) { (_) in }
                
                return
            }
            
            // Look throughout existing groups for a duplicate group name
            for route in existingRoutes {
                if route.name == routeName {
                    self.logger.debug("Duplicate route name not allowed")
                    
                    let notAllowedController = UIAlertController(title: "Error", message: "Route name already exists", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (_) in
                        self.presentViewController(newRouteController, animated: true, completion: nil)
                    }
                    
                    notAllowedController.addAction(okButton)
                    
                    self.presentViewController(notAllowedController, animated: true) { (_) in }
                    
                    return
                }
            }
            
            if self.groupTable!.selectedIndex == -1 {
                self.logger.debug("Must select group for new route")
                
                let notAllowedController = UIAlertController(title: "Error", message: "You must select a group", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (_) in
                    self.presentViewController(newRouteController, animated: true, completion: nil)
                }
                
                notAllowedController.addAction(okButton)
                
                self.presentViewController(notAllowedController, animated: true) { (_) in }
                
                return
            }
            
            // Get our list of groups
            let existingGroups = getObjects(Const.Data.Group, nil) as [Group]
            var targetGroup = existingGroups[self.groupTable!.selectedIndex]
            
            // Create our group and save it to CoreData
            let newRoute = insertObject(Const.Data.Route) as? Route
            newRoute!.name = routeName
            newRoute!.group = targetGroup
            
            // Add the new route to the group's route list
            var mutableRoutes = targetGroup.routes.mutableCopy() as NSMutableOrderedSet
            mutableRoutes.addObject(newRoute!)
            targetGroup.routes = mutableRoutes.copy() as NSOrderedSet
            
            save()
            
            self.logger.debug("Creating route: \(routeName) in group: \(targetGroup.name)")
            
            // Update the route table
            self.routeTable!.populateDataSource()
            self.routeTable!.tableView.reloadSections(NSIndexSet(index: self.groupTable!.selectedIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (_) in
            self.logger.debug("Add group cancelled by user")
        }
        
        newRouteController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Route Name"
        }
        
        // Create a container view to display possible desination groups
        let containerViewWidth = 250
        let containerViewHeight = 140
        var containerFrame = CGRectMake(10, 95, CGFloat(containerViewWidth), CGFloat(containerViewHeight))
        alertView = UIView(frame: containerFrame)
        
        groupTable = GroupTableViewController()
        groupTable!.view.frame = CGRect(origin: CGPointZero, size: containerFrame.size)
        groupTable!.view.tag = -2
        alertView!.addSubview(groupTable!.view)
        alertView!.tag = -1

        newRouteController.view.addSubview(alertView!)
        
        // Add constraints to make sure the alert controller view resizes itself properly
        var cons:NSLayoutConstraint = NSLayoutConstraint(item: newRouteController.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: alertView!, attribute: NSLayoutAttribute.Height, multiplier: 1.00, constant: 155)
        
        newRouteController.view.addConstraint(cons)
        
        var cons2:NSLayoutConstraint = NSLayoutConstraint(item: newRouteController.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: alertView!, attribute: NSLayoutAttribute.Width, multiplier: 1.00, constant: 20)
        
        newRouteController.view.addConstraint(cons2)
        
        newRouteController.addAction(createAction)
        newRouteController.addAction(cancelAction)
        
        self.presentViewController(newRouteController, animated: true) { (_) in }
    }
    
    func reorder() {
        
    }
}

// MARK: - GroupTableViewController

class GroupTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Logger
    let logger = Swell.getLogger("GroupTableViewController")
    
    // Datasource variables
    var groupNames = [String]()
    var selectedIndex = -1
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateDataSource()
    }
    
    // MARK: - CoreData accessors
    
    func populateDataSource() {
        // Clear existing data sources
        groupNames = [String]()
        
        // Load all groups and their associated routes
        let groups = getObjects(Const.Data.Group, nil) as [Group]
        
        // Populate the section headers
        for group in groups {
            groupNames.append(group.name)
        }
        
        logger.debug("Data source populated - \(groupNames.count) groups")
    }
    
    // MARK: - UITableViewDelegate overrides
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.textLabel!.text = groupNames[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
    }
}

// MARK: - RouteTableViewController

// Implement a delegate callback for cell selection
@objc protocol RouteTableViewControllerDelegate {
    optional func cellSelected(indexPath: NSIndexPath)
}

class RouteTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Logger
    let logger = Swell.getLogger("RouteTableViewController")
    
    // Datasource variables
    var groupNames = [String]()
    var routeNames = [[String]]()
    var sessionCounts = [[Int]]()
    
    // Control variables
    var delegate: RouteTableViewControllerDelegate?
    var state = 0
    var curSection = -1
    var curRow = -1
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == Const.Segue.SessionsTable && state == 1 {
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Const.Segue.SessionsTable {
            let sessionNavContainer = segue.destinationViewController as UINavigationController
            let sessionTableVC = sessionNavContainer.viewControllers[0] as SessionTableViewController
            
            sessionTableVC.groupIndex = curSection
            sessionTableVC.routeIndex = curRow
        }
    }
    
    // MARK: - CoreData accessors
    
    // Populate UITableView data source
    func populateDataSource() {
        // Clear existing data sources
        groupNames = [String]()
        routeNames = [[String]]()
        sessionCounts = [[Int]]()
        
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
                if let myRoute = route as? Route {
                    tempRouteNames.append(myRoute.name)
                    tempSessionCounts.append(myRoute.session.count)
                }
            }
            
            routeNames.append(tempRouteNames)
            sessionCounts.append(tempSessionCounts)
        }
        
        logger.debug("Data source populated")
    }
    
    // MARK: - UITableViewDelegate overrides
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupNames.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeNames[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupNames[section]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if state == 1 {
            return false
        }
        
        if groupNames.count > 1 {
            return true
        }
        
        if routeNames[0].count > 1 {
            return true
        }
        
        return false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCellWithIdentifier(Const.Cell.Route) as? UITableViewCell {
            cell.textLabel!.text = "\(routeNames[indexPath.section][indexPath.row])"
            
            if sessionCounts[indexPath.section][indexPath.row] == 1 {
                cell.detailTextLabel!.text = "\(sessionCounts[indexPath.section][indexPath.row]) session"
            }
            else {
                cell.detailTextLabel!.text = "\(sessionCounts[indexPath.section][indexPath.row]) sessions"
            }
            
            return cell
        }
        
        logger.error("Did not recognize reusable cell")
        return UITableViewCell();
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if state == 1 {
            if delegate != nil {
                delegate!.cellSelected!(indexPath)
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        // Update the section and row
        curSection = indexPath.section
        curRow = indexPath.row
        
        // Manually perform the segue
        performSegueWithIdentifier(Const.Segue.SessionsTable, sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let allGroups = getObjects(Const.Data.Group, nil) as? [Group]
            let curGroup = allGroups![indexPath.section]
            let allRoutes = curGroup.routes
            let curRoute = allRoutes[indexPath.row] as Route
            
            var mutableRoutes = curGroup.routes.mutableCopy() as NSMutableOrderedSet
            managedObjectContext!.deleteObject(curRoute)
            mutableRoutes.removeObjectAtIndex(indexPath.row)
            curGroup.routes = mutableRoutes.copy() as NSOrderedSet
            
            self.tableView.beginUpdates()
            
            if curGroup.routes.count == 0 {
                managedObjectContext!.deleteObject(curGroup)
                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            save()
            self.populateDataSource()
            
            self.tableView.endUpdates()
        }
    }
}

// MARK: - SessionTableViewController

class SessionTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Logger
    let logger = Swell.getLogger("SessionTableViewController")
    
    // Datasource variables
    var groupIndex = -1
    var routeIndex = -1
    var sessionNames = [String]()
    var sessionDistances = [NSNumber]()
    var sessionTimes = [String]()
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // See if our group and route indices have been populated
        if groupIndex == -1 || routeIndex == -1 {
            logger.error("Group and/or route indices not populated")
        }
        
        populateDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func btnExitTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - CoreData accessors
    
    func populateDataSource() {
        // Get the latest data
        let groups = getObjects(Const.Data.Group, nil) as [Group]
        let route = groups[groupIndex].routes[routeIndex] as Route
        var sessions = route.session
        
        self.title = route.name
        
        sessionNames = [String]()
        sessionDistances = [NSNumber]()
        sessionTimes = [String]()
        
        sessions.enumerateObjectsUsingBlock { (session, index, stop) -> Void in
            if let curSession = session as? Session {
                self.sessionNames.append(curSession.name)
                self.sessionDistances.append(curSession.distance)
                self.sessionTimes.append(curSession.length)
            }
        }
        
        logger.debug("Data source populated")
    }
    
    // MARK: UITableView delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(Const.Cell.Session) as? UITableViewCell {
            cell.textLabel!.text = "\(sessionNames[indexPath.row])"
            
//            if sessionCounts[indexPath.section][indexPath.row] == 1 {
//                cell.detailTextLabel!.text = "\(sessionCounts[indexPath.section][indexPath.row]) session"
//            }
//            else {
//                cell.detailTextLabel!.text = "\(sessionCounts[indexPath.section][indexPath.row]) sessions"
//            }
            
            return cell
        }
        
        logger.error("Did not recognize reusable cell")
        return UITableViewCell();
    }
}
