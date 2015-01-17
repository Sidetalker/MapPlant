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

class RecordViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    // Map variables
    var mapView = MKMapView()
    
    // UIControls
    var state = 0
    var startReset: UIButton!
    var pauseResume: UIButton!
    
    // Location variables
    var locationManager = CLLocationManager()
    var lastLoc = [0.0, 0.0]
    var allLocations = [CLLocationCoordinate2D]()
    var allAccuracies = [CLLocationAccuracy]()
    
    // Logger
    let logger = Swell.getLogger("RecordViewController")
    
    // Device details
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Grab device details
        width = self.view.frame.size.width
        height = self.view.frame.size.height
        
        // Configure location manager + locations
        configureLocationManager()
        configureButtons()
        configureMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Initializations
    
    // Create and configure out buttons 
    func configureButtons() {
        startReset = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        startReset.frame = CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width / 2, 44)
        startReset.backgroundColor = UIColor.greenColor()
        startReset.addTarget(self, action: "startResetPressed", forControlEvents: UIControlEvents.TouchUpInside)
        startReset.setTitle("Start", forState: UIControlState.Normal)
        
        pauseResume = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        pauseResume.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, self.view.frame.size.width / 2, 44)
        pauseResume.backgroundColor = UIColor.lightGrayColor()
        pauseResume.addTarget(self, action: "pauseResumePressed", forControlEvents: UIControlEvents.TouchUpInside)
        pauseResume.setTitle("", forState: UIControlState.Normal)
        
        self.view.addSubview(startReset)
        self.view.addSubview(pauseResume)
    }
    
    // Create and configure the map
    func configureMap() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: width, height: height / 2))
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.delegate = self
        
        self.view.addSubview(mapView)
    }
    
    // Configure location manager
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Button handlers
    
    func startResetPressed() {
        Swell.debug("startResetPressed")
        
        
    }
    
    func pauseResumePressed() {
        Swell.debug("pauseResume")
    }
    
    // MARK: - Location manager delegates
    
    // Handle location manager failures
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        
        if (error != nil) {
            Swell.error("Location manager failed with error: \(error)")
        }
    }
    
    // Log location updates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation = true
        
        let lat = locationManager.location.coordinate.latitude
        let long = locationManager.location.coordinate.longitude
        let accuracy = locationManager.location.horizontalAccuracy
        
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        
        // Only save the location if it's not the same as the last one
        if lat != lastLoc[0] || long != lastLoc[1] {
            allLocations.append(coordinate)
            allAccuracies.append(accuracy)
            lastLoc = [lat, long]
        }
    }
    
    // MARK: - Map delegates
    
    // Handle user location updates passed to the map
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        // Gather location info
        var location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var region = MKCoordinateRegion(center: location, span: span)
        
        // Zoom to the generated region
        mapView.setRegion(region, animated: true)
        
        // If we have at least two locations, create a polyline from all locations
        if allLocations.count > 1 {
            let polyline = MKPolyline(coordinates: &allLocations, count: allLocations.count)
            
            mapView.addOverlay(polyline)
        }
    }

    // Handle polyline drawing
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.redColor()
            renderer.lineWidth = 4
        
            return renderer
        }
        
        return nil
    }
}