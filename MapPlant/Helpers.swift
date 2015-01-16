//
//  Helpers.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import CoreData

// Logger
let logger = Swell.getLogger("Helpers")

// Inserts an object into the CoreData stack and the new object
func insertObject(name: String) -> AnyObject {
    logger.debug("Inserting new object into \(name)")
    
    let managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext { return managedObjectContext }
        else { return nil } }()
    
    return NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: managedObjectContext!)
}

// Fetches all specified records from the CoreData stack
func getObjects(name: String, predicate: NSPredicate?) -> [AnyObject] {
    logger.debug("Fetching records from \(name) with predicate \(predicate)")
    
    let fetchRequest = NSFetchRequest(entityName: name)
    fetchRequest.predicate = predicate
    
    let managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext { return managedObjectContext }
        else { return nil } }()
    
    // TODO: - Error handling
    return managedObjectContext!.executeFetchRequest(fetchRequest, error: nil)!
}