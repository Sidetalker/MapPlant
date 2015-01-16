//
//  Session.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var locationSet: LocationSet
    @NSManaged var route: Route
    @NSManaged var tags: NSSet

}
