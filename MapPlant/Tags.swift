//
//  Tags.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import Foundation
import CoreData

class Tags: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var session: Session
    @NSManaged var route: Route
    @NSManaged var group: Group

}
