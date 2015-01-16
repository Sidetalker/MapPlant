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
    @IBOutlet weak var mapView: MKMapView!
    
    // Location variables
    var locationManager = CLLocationManager()
    var lastLoc: Location?
    
    // Logger
    let logger = Swell.getLogger("RecordViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let location = CLLocationCoordinate2D(
            latitude: 51.50007773,
            longitude: -0.1246402
        )
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        //3
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = "Big Ben"
        annotation.subtitle = "London"
        mapView.addAnnotation(annotation)
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
        
        lastLoc = location
        
        if let last = lastLoc {
            if last.long != location.long || last.lat != location.lat {
                Swell.debug("\(location.lat), \(location.long) - \(location.accuracy)")
            }
        }
    }
}