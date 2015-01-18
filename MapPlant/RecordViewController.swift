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
    var polyline = MKPolyline()
    var lineColor = UIColor.redColor()
    var lineWidth: CGFloat = 2.5
    
    // UIControls
    var state = Const.RecordState.Stopped
    var focus = Const.RecordMap.FocusOn
    var startStop: UIButton!
    var clearQuit: UIButton!
    var toggleFocus: UIButton!
    
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
        startStop = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        startStop.frame = CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width / 2 - 22, 44)
        startStop.backgroundColor = UIColor.greenColor()
        startStop.addTarget(self, action: "startStopPressed", forControlEvents: UIControlEvents.TouchUpInside)
        startStop.setTitle("Start", forState: UIControlState.Normal)
        
        clearQuit = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        clearQuit.frame = CGRectMake(self.view.frame.size.width / 2 + 22, self.view.frame.size.height / 2, self.view.frame.size.width / 2 - 22, 44)
        clearQuit.backgroundColor = UIColor.darkGrayColor()
        clearQuit.addTarget(self, action: "clearQuitPressed", forControlEvents: UIControlEvents.TouchUpInside)
        clearQuit.setTitle("Quit", forState: UIControlState.Normal)
        
        toggleFocus = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        toggleFocus.frame = CGRectMake(self.view.frame.size.width / 2 - 22, self.view.frame.size.height / 2, 44, 44)
        toggleFocus.backgroundColor = UIColor.blueColor()
        toggleFocus.addTarget(self, action: "toggleFocusPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startStop)
        self.view.addSubview(clearQuit)
        self.view.addSubview(toggleFocus)
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
    }
    
    // MARK: - Button handlers
    
    func toggleFocusPressed() {
        if focus == Const.RecordMap.FocusOn {
            logger.debug("Focus Off")
            mapView.showsUserLocation = false
            toggleFocus.backgroundColor = UIColor.lightGrayColor()
            focus = Const.RecordMap.FocusOff
        }
        else {
            logger.debug("Focus On")
            mapView.showsUserLocation = true
            toggleFocus.backgroundColor = UIColor.blueColor()
            focus = Const.RecordMap.FocusOn
        }
    }
    
    func startStopPressed() {
        switch state {
        case Const.RecordState.Stopped:
            startRecording()
        case Const.RecordState.Running:
            stopRecording()
        default:
            logger.error("Unrecognized State")
        }
    }
    
    func startRecording() {
        logger.debug("Started Recording")
        
        // Change state
        state = Const.RecordState.Running
        
        // Update buttons
        startStop.backgroundColor = UIColor.orangeColor()
        startStop.setTitle("Stop", forState: UIControlState.Normal)
        
        clearQuit.backgroundColor = UIColor.redColor()
        clearQuit.setTitle("Reset", forState: UIControlState.Normal)
        
        // Begin recording location again
        locationManager.startUpdatingLocation()
    }
    
    func stopRecording() {
        logger.debug("Stopped Recording")
        
        // Change state
        state = Const.RecordState.Stopped
        
        // Update buttons
        clearQuit.backgroundColor = UIColor.darkGrayColor()
        clearQuit.setTitle("Quit", forState: UIControlState.Normal)
        
        startStop.backgroundColor = UIColor.greenColor()
        startStop.setTitle("Start", forState: UIControlState.Normal)
        
        // Stop recording user location
        locationManager.stopUpdatingLocation()
    }
    
    func clearQuitPressed() {
        switch state {
        case Const.RecordState.Stopped:
            logger.debug("Quitting Record")
            self.dismissViewControllerAnimated(true, completion: nil)
        case Const.RecordState.Running:
            logger.debug("Clearing all Data")
            allLocations = [CLLocationCoordinate2D]()
            allAccuracies = [CLLocationAccuracy]()
            
            for overlay in mapView.overlays {
                mapView.removeOverlay(overlay as MKOverlay)
            }
        default:
            logger.error("Unrecognized State")
        }
    }
    
    // MARK: - Location manager delegates
    
    // Handle location manager failures
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        
        if (error != nil) {
            logger.error("Location manager failed with error: \(error)")
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
        
        // If we have at least two locations, create a polyline from all locations
        if allLocations.count > 1 {
            polyline = MKPolyline(coordinates: &allLocations, count: allLocations.count)
            
            mapView.addOverlay(polyline)
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
    }

    // Handle polyline drawing
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = lineColor
            renderer.lineWidth = lineWidth
        
            return renderer
        }
        
        return nil
    }
}