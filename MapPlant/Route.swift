//
//  Route.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import Foundation
import CoreData

class Route: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var session: NSOrderedSet
    @NSManaged var group: Group
    @NSManaged var tags: Tags

}
