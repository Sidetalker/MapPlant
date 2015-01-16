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

let managedObjectContext : NSManagedObjectContext? = {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    if let managedObjectContext = appDelegate.managedObjectContext { return managedObjectContext }
    else { return nil } }()

// Inserts an object into the CoreData stack and the new object
func insertObject(name: String) -> AnyObject {
    logger.debug("Inserting new object into \(name)")
    
    return NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: managedObjectContext!)
}

// Fetches all specified records from the CoreData stack
func getObjects(name: String, predicate: NSPredicate?) -> [AnyObject] {
    logger.debug("Fetching records from \(name) with predicate \(predicate)")
    
    let fetchRequest = NSFetchRequest(entityName: name)
    fetchRequest.predicate = predicate
    
    // TODO: - Error handling
    return managedObjectContext!.executeFetchRequest(fetchRequest, error: nil)!
}

// Saves the CoreData stacks
func save() {
    var error : NSError?
    if (managedObjectContext!.save(&error) ) {
        println(error?.localizedDescription)
    }
}