//
//  RecordingViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RecordViewController: UIViewController, CLLocationManagerDelegate {
    // Map variables
//    @IBOutlet weak var mapView: MKMapView!
    var mapView = MKMapView()
    
    // Location variables
    var locationManager = CLLocationManager()
    var lastLoc: Location?
    
    // Logger
    let logger = Swell.getLogger("RecordViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure map view
        mapView.showsUserLocation = true
        
        // Configure location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Location manager delegates
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()

        if (error != nil) {
            Swell.error("Location manager failed with error: \(error)")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = insertObject(Const.Data.Location) as Location
        
        location.lat = locationManager.location.coordinate.latitude
        location.long = locationManager.location.coordinate.longitude
        location.accuracy = locationManager.location.horizontalAccuracy
        
        if let last = lastLoc {
            if last.long != location.long || last.lat != location.lat {
                Swell.debug("\(location.lat), \(location.long) - \(location.accuracy)")
            }
        }
        
        lastLoc = location
    }
}