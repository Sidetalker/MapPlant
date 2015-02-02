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
    
    managedObjectContext!.save(&error)
    
    if error != nil {
        println(error?.localizedDescription)
    }
}

// Extends arrays to access the last index with a .last
extension Array {
    var last: T {
        return self[self.endIndex - 1]
    }
}

// Easy random number functionality
func randomFloatBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

// Easy random number functionality
func randomIntBetweenNumbers(firstNum: Int, secondNum: Int) -> Int {
    let first = CGFloat(firstNum)
    let second = CGFloat(secondNum)
    let random = randomFloatBetweenNumbers(first, second)
    
    return Int(random)
}

// Super handy function to delay something
func delay(delay: Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

