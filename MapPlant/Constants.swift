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
        static let Initialized = 0
        static let Running = 1
        static let Paused = 2
    }
    
    struct RecordMap {
        static let TrackAndDraw = 0
        static let TrackOnly = 1
        static let DrawOnly = 2
    }
}