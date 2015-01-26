//
//  Constants.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

struct Const {
    struct Data {
        static let LogBook = "LogBook"
        static let Tags = "Tags"
        static let Route = "Route"
        static let LocationSet = "LocationSet"
        static let Group = "Group"
        static let Location = "Location"
        static let Session = "Session"
    }
    
    struct Record {
        static let Running = 0
        static let Stopped = 1
        static let FocusOn = 2
        static let FocusOff = 3
        static let ButtonHeight: CGFloat = 44
    }
    
    struct Cell {
        static let Route = "routeCell"
    }
    
    struct Segue {
        static let RecordToSave = "segueRecordSave"
        static let RoutesTable = "segueRouteTableEmbed"
        static let SaveRouteSelection = "segueSaveRouteSelection"
        static let SessionsTable = "segueSessionsTable"
    }
}