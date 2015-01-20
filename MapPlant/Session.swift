//
//  MapPlant.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/20/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var name: String
    @NSManaged var distance: NSNumber
    @NSManaged var length: String
    @NSManaged var locationSet: LocationSet
    @NSManaged var route: Route
    @NSManaged var tags: NSSet

}
