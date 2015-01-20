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
            routeTable?.parent = self
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
        editController.addAction(reorder)
        editController.addAction(cancelAction)
        
        self.presentViewController(editController, animated: true) { (_) in
        }
    }
    
    // Handles user input for adding a new group
    func addGroup() {
        logger.debug("Adding a new group")
        
        let newGroupController = UIAlertController(title: "Add Group", message: "Enter the new group and routes name", preferredStyle: UIAlertControllerStyle.Alert)
        
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
    
    // Parent reference
    var parent: RouteTableContainer?
    
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

class RouteTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    // Logger
    let logger = Swell.getLogger("RouteTableViewController")
    
    // Datasource variables
    var groupNames = [String]()
    var routeNames = [[String]]()
    var sessionCounts = [[Int]]()
    
    // Parent reference
    var parent: RouteTableContainer?
    
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
                tempRouteNames.append(route.name)
                tempSessionCounts.append(routes.count)
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // This will be the case for programmatically loaded cells (see viewDidLoad to switch approaches)
        if let cell = tableView.dequeueReusableCellWithIdentifier(Const.Cell.Route) as? UITableViewCell {
            cell.textLabel!.text = "\(routeNames[indexPath.section][indexPath.row]) - \(sessionCounts[indexPath.section][indexPath.row])"
            return cell
        }
        
        logger.error("Did not recognize reusable cell")
        return UITableViewCell();
    }
}

// MARK: - SessionTableViewController

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
}
