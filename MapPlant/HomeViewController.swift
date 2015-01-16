//
//  ViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/13/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext { return managedObjectContext }
        else { return nil } }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if managedObjectContext == nil {
            Swell.error("Could not load managedObjectContext")
        } else {
            Swell.info("managedObjectContext successfully loaded")
        }
        
        createTestRoute()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        loadTestRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTestRoute() {
        let testRoute = insertObject(Const.Data.Route) as Route
        
        testRoute.name = "Test Route"
    }
    
    func loadTestRoute() {
        let routes = getObjects(Const.Data.Route) as [Route]
        
        Swell.info("We retrieved \(routes.count) routes - the first on is named \(routes[0].name)")
    }
}

