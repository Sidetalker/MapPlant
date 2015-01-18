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
    var btnStartStop: UIButton!
    var btnClearQuit: UIButton!
    var btnToggleFocus: UIButton!
    var btnFinishRecording: UIButton!
    var lblLocation: UILabel!
    
    // State variables
    var state = Const.Record.Stopped
    var focus = Const.Record.FocusOn
    
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
        configureLabels()
        configureMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Initializations
    
    func configureLabels() {
        lblLocation = UILabel()
        lblLocation.frame = CGRect(x: 10, y: height / 2 + Const.Record.ButtonHeight + 10, width: 0, height: 0)
        lblLocation.font = UIFont(name: "Courier", size: 11)
        lblLocation.text = "Lat: NULL\nLong: NULL\nAccuracy: NULL\nLocations: 0"
        lblLocation.numberOfLines = 4
        lblLocation.sizeToFit()
    
        let finalPoint = lblLocation.frame.origin
        let finalSize = CGSize(width: width / 2, height: lblLocation.frame.size.height)
        
        lblLocation.frame = CGRect(origin: finalPoint, size: finalSize)
        
        self.view.addSubview(lblLocation)
    }
    
    // Create and configure our buttons 
    func configureButtons() {
        btnStartStop = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        btnStartStop.frame = CGRectMake(0, height / 2, width / 2 - 22, Const.Record.ButtonHeight)
        btnStartStop.backgroundColor = UIColor.greenColor()
        btnStartStop.addTarget(self, action: "btnStartStopPressed", forControlEvents: UIControlEvents.TouchUpInside)
        btnStartStop.setTitle("Start", forState: UIControlState.Normal)
        
        btnClearQuit = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        btnClearQuit.frame = CGRectMake(width / 2 + 22, height / 2, width / 2 - 22, Const.Record.ButtonHeight)
        btnClearQuit.backgroundColor = UIColor.darkGrayColor()
        btnClearQuit.addTarget(self, action: "btnClearQuitPressed", forControlEvents: UIControlEvents.TouchUpInside)
        btnClearQuit.setTitle("Quit", forState: UIControlState.Normal)
        
        btnToggleFocus = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        btnToggleFocus.frame = CGRectMake(width / 2 - 22, height / 2, 44, Const.Record.ButtonHeight)
        btnToggleFocus.backgroundColor = UIColor.blueColor()
        btnToggleFocus.addTarget(self, action: "btnToggleFocusPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnFinishRecording = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        btnFinishRecording.frame = CGRectMake(0, height - Const.Record.ButtonHeight, width, Const.Record.ButtonHeight)
        btnFinishRecording.backgroundColor = UIColor.purpleColor()
        btnFinishRecording.addTarget(self, action: "btnFinishRecordingPressed", forControlEvents: UIControlEvents.TouchUpInside)
        btnFinishRecording.setTitle("Finish Recording", forState: UIControlState.Normal)
        
        self.view.addSubview(btnStartStop)
        self.view.addSubview(btnClearQuit)
        self.view.addSubview(btnToggleFocus)
        self.view.addSubview(btnFinishRecording)
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
    
    // Save the location data to CoreData store and transition to
    func btnFinishRecordingPressed() {
        logger.debug("Finishing Recording")
        
        // Make sure the location count matches the accuracy count
        if allLocations.count != allAccuracies.count {
            logger.error("Location count doesn't match accuracy count")
            return
        }
        
        // Make sure we HAVE a location
        if allLocations.count == 0 {
            logger.error("We don't have any locations logged you moron!")
            return
        }
        
        // Create a location set
        let locationSet = insertObject(Const.Data.LocationSet) as LocationSet
        let session = insertObject(Const.Data.Session) as Session
        var route: Route!
        
        locationSet.session = session
        
        session.name = "New Session"
        session.date = NSDate()
        session.locationSet = locationSet
        
        var tempLocations = [Location]()
        
        // Save all locations to CoreData
        for i in 0...allLocations.count - 1 {
            let location = insertObject(Const.Data.Location) as Location
            
            location.lat = allLocations[i].latitude as Double
            location.long = allLocations[i].longitude as Double
            location.accuracy = allAccuracies[i] as Double
            location.locationSet = locationSet
            
            tempLocations.append(location)
            
            save()
        }
        
        locationSet.locations = NSOrderedSet(array: tempLocations)
    }
    
    // Enable / disable display and tracking of blue dot on map
    func btnToggleFocusPressed() {
        if focus == Const.Record.FocusOn {
            logger.debug("Focus Off")
            mapView.showsUserLocation = false
            btnToggleFocus.backgroundColor = UIColor.lightGrayColor()
            focus = Const.Record.FocusOff
        }
        else {
            logger.debug("Focus On")
            mapView.showsUserLocation = true
            btnToggleFocus.backgroundColor = UIColor.blueColor()
            focus = Const.Record.FocusOn
        }
    }
    
    // Start or stop location logging
    func btnStartStopPressed() {
        switch state {
        case Const.Record.Stopped:
            startRecording()
        case Const.Record.Running:
            stopRecording()
        default:
            logger.error("Unrecognized State")
        }
    }
    
    // Update state, location manager and buttons to begin recording
    func startRecording() {
        logger.debug("Started Recording")
        
        // Change state
        state = Const.Record.Running
        
        // Update buttons
        btnStartStop.backgroundColor = UIColor.orangeColor()
        btnStartStop.setTitle("Stop", forState: UIControlState.Normal)
        
        btnClearQuit.backgroundColor = UIColor.redColor()
        btnClearQuit.setTitle("Reset", forState: UIControlState.Normal)
        
        // Begin recording location again
        locationManager.startUpdatingLocation()
    }
    
    // Update state, location manager and buttons to stop recording
    func stopRecording() {
        logger.debug("Stopped Recording")
        
        // Change state
        state = Const.Record.Stopped
        
        // Update buttons
        btnClearQuit.backgroundColor = UIColor.darkGrayColor()
        btnClearQuit.setTitle("Quit", forState: UIControlState.Normal)
        
        btnStartStop.backgroundColor = UIColor.greenColor()
        btnStartStop.setTitle("Start", forState: UIControlState.Normal)
        
        // Stop recording user location
        locationManager.stopUpdatingLocation()
    }
    
    // Clear the location data or exit depending on state
    func btnClearQuitPressed() {
        switch state {
        case Const.Record.Stopped:
            logger.debug("Quitting Record")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        case Const.Record.Running:
            logger.debug("Clearing all Data")
            
            allLocations = [CLLocationCoordinate2D]()
            allAccuracies = [CLLocationAccuracy]()
            
            lblLocation.text = "Lat: NULL\nLong: NULL\nAccuracy: NULL\nLocations: 0"
            
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
            
            lblLocation.text = "Lat: \(lat)°\nLong: \(long)°\nAccuracy: \(round(accuracy)) ft.\nLocations: \(allLocations.count)"
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