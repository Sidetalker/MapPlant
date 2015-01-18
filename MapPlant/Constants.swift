//
//  Constants.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

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
    
    struct RecordState {
        static let Running = 1
        static let Stopped = 0
    }
    
    struct RecordMap {
        static let FocusOn = 0
        static let FocusOff = 1
    }
}