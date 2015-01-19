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
    // Logger configuration
    let logger = Swell.getLogger("HomeViewController")

    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        generateDefaults()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Generates default group and route if CoreData is unpopulated
    func generateDefaults() {
        let routes = getObjects(Const.Data.Route, nil) as [Route]
        let groups = getObjects(Const.Data.Group, nil) as [Group]
        
        var defaultGroup: Group?
        var defaultRoute: Route?
        
        if groups.count == 0 {
            logger.debug("Generated default group")
            
            defaultGroup = insertObject(Const.Data.Group) as? Group
            defaultGroup!.name = "My First Group"
            
            save()
        }
        else {
            defaultGroup = groups[0]
        }
        
        if routes.count == 0 {
            logger.debug("Generated default route")
            
            defaultRoute = insertObject(Const.Data.Route) as? Route
            defaultRoute!.name = "My First Route"
            defaultRoute!.group = defaultGroup!
            
            save()
        }
    }
}

