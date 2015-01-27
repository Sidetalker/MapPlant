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

// MARK: - RecordSaveViewController

class RecordSaveViewController: UITableViewController, UITableViewDelegate, RouteTableViewControllerDelegate {
    // IBOutlets
    @IBOutlet weak var lblSessionName: UILabel!
    @IBOutlet weak var lblSessionTimestamp: UILabel!
    @IBOutlet weak var lblRouteName: UILabel!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblDataPointCount: UILabel!
    @IBOutlet weak var lblSessionTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    // Matching variables
    var sessionName = "My New Session"
    var sessionTimestamp = NSDate()
    var routeName = "My New Route"
    var groupName = "My New Group"
    var dataPoints = -1
    var length = "00:00"
    var distance = 0.0
    
    // CoreData
    var locationSet: LocationSet?
    var route: Route?
    var sessionEntity: Session?
    var groupIndex = -1
    var routeIndex = -1
    
    // MARK: - UITableViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Generate or rewire this session's CoreData entity
    override func viewWillAppear(animated: Bool) {
        if sessionEntity == nil {
            logger.error("sessionEntity is nil - it should always be populated in the parent's segue prep")
        }
        else if route == nil {
            let existingGroups = getObjects(Const.Data.Group, nil) as [Group]
            let firstGroupRoute = existingGroups[0].routes[0] as Route
            
            groupName = existingGroups[0].name
            routeName = firstGroupRoute.name
            groupIndex = 0
            routeIndex = 0
            route = firstGroupRoute
            sessionName = sessionEntity!.name
            sessionTimestamp = sessionEntity!.date
        }
        else {
            logger.error("route is nil - it should always be populated in the else if statement above this")
        }
        
        update()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Const.Segue.SaveRouteSelection {
            let routesTable = segue.destinationViewController as? RouteTableViewController
            
            routesTable!.state = 1
            routesTable!.delegate = self
        }
        
        return
    }
    
    // MARK: - UI Management
    
    func update() {
        updateSessionEntity()
        updateUI()
        save()
    }
    
    func updateSessionEntity() {
        sessionEntity!.name = sessionName
        sessionEntity!.distance = distance
        sessionEntity!.length = length
        sessionEntity!.date = sessionTimestamp
        sessionEntity!.locationSet = locationSet!
        sessionEntity!.route = route!
        
    }
    
    func updateUI() {
        // Format our date string
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/DD/YY | HH:MM:SS"
        let dateString = dateFormatter.stringFromDate(sessionTimestamp)
        
        lblSessionName.text = sessionName
        lblSessionTimestamp.text = dateString
        lblSessionTime.text = length
        lblRouteName.text = routeName
        lblGroupName.text = groupName
        lblDistance.text = "\(round(distance * 100)/100) meters"
        
        if locationSet != nil {
            lblDataPointCount.text = "\(locationSet!.locations.count)"
        }
        else {
            lblDataPointCount.text = "nil"
        }
    }
    
    // MARK: - UITableView delegates
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // Name change cell
                let nameChanger = UIAlertController(title: "Name Your Session", message: "Enter a name for your new session", preferredStyle: UIAlertControllerStyle.Alert)
                
                nameChanger.addTextFieldWithConfigurationHandler { (textField) in
                    textField.placeholder = "Session Name"
                }
                
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (_) in
                    let nameField = nameChanger.textFields![0] as UITextField
                    self.sessionName = nameField.text
                    
                    self.update()
                })
                
                nameChanger.addAction(ok)
                self.presentViewController(nameChanger, animated: true, completion: { (_) in
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true) })
                
            }
            else if indexPath.row == 1 {
                // Route / Group
                update()
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // Save the session to the selected route
                update()
                
                var mutableSessions = NSMutableOrderedSet(orderedSet: route!.session)
                mutableSessions.addObject(sessionEntity!)
                route!.session = NSOrderedSet(orderedSet: mutableSessions)
                sessionEntity!.route = route!
                
                // Dismiss everything (how?!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else if indexPath.row == 1 {
                // Go back to the recording screen
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else if indexPath.row == 2 {
                // Prompt for destruction
            }
        }
    }
    
    // MARK: - RouteTableViewController delegate
    
    func cellSelected(indexPath: NSIndexPath) {
        let existingGroups = getObjects(Const.Data.Group, nil) as [Group]
        let selectedGroup = existingGroups[indexPath.section] as Group
        let selectedRoute = selectedGroup.routes[indexPath.row] as Route
        
        groupName = selectedGroup.name
        routeName = selectedRoute.name
        groupIndex = indexPath.section
        routeIndex = indexPath.row
        route = selectedRoute
        sessionEntity!.route = route!
        
        update()
    }
}

// MARK - RecordViewController

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
    var lblInfo: UILabel!
    
    // State variables
    var state = Const.Record.Stopped
    var focus = Const.Record.FocusOn
    var startTime = NSDate()
    var session: Session?
    
    // Location variables
    var locationManager = CLLocationManager()
    var lastLoc = [0.0, 0.0]
    var allLocations = [CLLocationCoordinate2D]()
    var allAccuracies = [CLLocationAccuracy]()
    var allTimes = [NSDate]()
    var distance = 0.0
    
    // Logger
    let logger = Swell.getLogger("RecordViewController")
    
    // Device details
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    // CoreData
    var locationSet: LocationSet?
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Const.Segue.RecordToSave {
            let saveVC = segue.destinationViewController as RecordSaveViewController
            
            let timeInterval = NSDate().timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
            let minutes = floor(timeInterval/60)
            let seconds = round(timeInterval - minutes * 60)
            
            let lengthString = NSString(format: "%02d:%02d", minutes, seconds)
            
            saveVC.length = lengthString
            saveVC.dataPoints = allLocations.count
            saveVC.distance = distance
            saveVC.sessionTimestamp = startTime
            saveVC.locationSet = locationSet
            saveVC.sessionEntity = session!
        }
    }
    
    // MARK: - Initializations
    
    func configureLabels() {
        lblInfo = UILabel()
        lblInfo.frame = CGRect(x: 10, y: height / 2 + Const.Record.ButtonHeight + 10, width: 0, height: 0)
        lblInfo.font = UIFont(name: "Courier", size: 14)
        lblInfo.text = "Lat: NULL\nLong: NULL\nAccuracy: NULL\nLocations: 0\nTime: 00:00\nDistance: 0 meters"
        lblInfo.numberOfLines = 6
        lblInfo.sizeToFit()
    
        let finalPoint = lblInfo.frame.origin
        let finalSize = CGSize(width: width, height: lblInfo.frame.size.height)
        
        lblInfo.frame = CGRect(origin: finalPoint, size: finalSize)
        
        self.view.addSubview(lblInfo)
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
        
        // Stop the presses!!!
        stopRecording()
        
        if locationSet == nil {
            // Create a location set
            locationSet = insertObject(Const.Data.LocationSet) as? LocationSet
            session = insertObject(Const.Data.Session) as? Session
            var route: Route!
            
            locationSet!.session = session!
            
            session!.name = "New Session"
            session!.date = NSDate()
            session!.locationSet = locationSet!
        }
        
        var tempLocations = [Location]()
        
        // Save all locations to CoreData
        for i in 0...allLocations.count - 1 {
            let location = insertObject(Const.Data.Location) as Location
            
            location.lat = allLocations[i].latitude as Double
            location.long = allLocations[i].longitude as Double
            location.accuracy = allAccuracies[i] as Double
            location.locationSet = locationSet!
            location.timestamp = allTimes[i]
            
            tempLocations.append(location)
        }
        
        locationSet!.locations = NSOrderedSet(array: tempLocations)
        
        save()
        
        performSegueWithIdentifier(Const.Segue.RecordToSave, sender: self)
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
            startTime = NSDate()
            distance = 0.0
            
            lblInfo.text = "Lat: NULL\nLong: NULL\nAccuracy: NULL\nLocations: 0\nTime: 00:00\nDistance: 0 meters"
            
            if mapView.overlays != nil {
                for overlay in mapView.overlays {
                    mapView.removeOverlay(overlay as MKOverlay)
                }
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
            // Store the latest location data
            allLocations.append(coordinate)
            allAccuracies.append(accuracy)
            allTimes.append(NSDate())
            
            // Determine the current record time
            let curTime = NSDate().timeIntervalSinceReferenceDate
            var elapsedTime: NSTimeInterval = curTime - startTime.timeIntervalSinceReferenceDate
            
            let minutes = UInt8(elapsedTime / 60.0)
            elapsedTime -= NSTimeInterval(minutes) * 60
            
            let seconds = UInt8(elapsedTime)
            elapsedTime -= NSTimeInterval(seconds)
            
            let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
            let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
            
            let timeString = "\(strMinutes):\(strSeconds)"
            
            // Update the total distance
            if lastLoc[0] != 0 || lastLoc[1] != 0 {
                let lastDistance = locationManager.location.distanceFromLocation(CLLocation(latitude: lastLoc[0], longitude: lastLoc[1]))
                
                distance += lastDistance
            }
            
            // Update the previous location variable
            lastLoc = [lat, long]
            
            // Update the information label
            lblInfo.text = "Lat: \(lat)°\nLong: \(long)°\nAccuracy: \(round(accuracy)) ft.\nLocations: \(allLocations.count)\nTime: \(timeString)\nDistance: \(round(distance * 100)/100) meters"
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