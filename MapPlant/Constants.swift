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
        static let Session = "sessionCell"
    }
    
    struct Segue {
        static let RecordToSave = "segueRecordSave"
        static let RoutesTable = "segueRouteTableEmbed"
        static let SaveRouteSelection = "segueSaveRouteSelection"
        static let SessionsTable = "segueSessionsTable"
        static let BusfinderMainScreen = "segueBusfinderMain"
        static let BusfinderMapScreen = "segueBusfinderMap"
    }
    
    struct Image {
        static let BusfinderLogo = "BusfinderLogo.png"
        static let BusfinderLoginBG = "BusfinderLoginBG.jpg"
        static let ClearButton = "ClearWhite.png"
        static let ClearButtonPressed = "ClearWhitePressed.png"
        static let HeadshotA = "headshot1.jpg"
        static let HeadshotB = "headshot2.jpg"
    }
    
    struct View {
        static let BusfinderMapScreen = "busfinderMapScreen"
    }
    
    struct Tag {
        struct dropStatView {
            static let StatusImage = 111
            static let InfoLabel = 112
        }
    }
    
    struct Nib {
        static let DropStatView = "DropStatView"
    }
}