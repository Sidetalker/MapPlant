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
    //    @IBOutlet weak var mapView: MKMapView!
    var mapView = MKMapView()
    
    // Location variables
    var locationManager = CLLocationManager()
    var lastLoc: Location?
    
    // Logger
    let logger = Swell.getLogger("RecordViewController")
    
    // Device details
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Grab device details
        width = self.view.frame.size.width
        height = self.view.frame.size.height
        
        // Create and configure the map
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: width, height: height / 2))
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.delegate = self
        
        // Add our subviews to main view
        self.view.addSubview(mapView)
        
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
    
    // Handle location manager failures
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        
        if (error != nil) {
            Swell.error("Location manager failed with error: \(error)")
        }
    }
    
    // Log location updates
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
        save()
    }
    
    // MARK: - Map delegates
    
    // Handle user location updates passed to the map
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        // Gather location info
        var location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        var span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        var region = MKCoordinateRegion(center: location, span: span)
        
        // Zoom to the generated region
        mapView.setRegion(region, animated: true)
        
        Swell.debug("Map received user location update")
        
        // Retrieve all locations
        let locations = getObjects(Const.Data.Location, nil) as [Location]
        
        // If we have at least two locations, create a polyline from all locations
        if locations.count > 1 {
            var coords = [CLLocationCoordinate2D]()
            
            for location in locations {
                let curCoord = CLLocationCoordinate2D(latitude: location.lat as CLLocationDegrees, longitude: location.long as CLLocationDegrees)
                coords.append(curCoord)
            }
            
            let polyline = MKPolyline(coordinates: &coords, count: coords.count)
            
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