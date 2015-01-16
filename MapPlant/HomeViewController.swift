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
    // Logger
    let logger = Swell.getLogger("HomeViewController")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure logging
        //Swell.configureLogger("HomeViewController", level: LogLevel.DEBUG, formatter: LogFormatter.logFormatterForString("HomeVC"))
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func createTestRoute() {
        let testRoute = insertObject(Const.Data.Route) as Route
        
        testRoute.name = "Test Route"
    }
    
    func loadTestRoute() {
        let routes = getObjects(Const.Data.Route, nil) as [Route]
        
        logger.info("We retrieved \(routes.count) routes - the first one is named \(routes[0].name)")
    }
}

