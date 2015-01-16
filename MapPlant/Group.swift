//
//  Group.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import Foundation
import CoreData

class Group: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var routes: NSOrderedSet
    @NSManaged var logBook: LogBook
    @NSManaged var tags: Tags

}
