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
    }
    
    // MARK: - Map delegates
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        // Gather location info
        var location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        var span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        var region = MKCoordinateRegion(center: location, span: span)
        
        // Zoom to the generated region
        mapView.setRegion(region, animated: true)
        
        Swell.debug("Map received user location update")
    }
    
    
    
//    - (void)viewDidLoad {
//    [super viewDidLoad];
//    mapView = [[MKMapView alloc]
//    initWithFrame:CGRectMake(0,
//    0,
//    self.view.bounds.size.width,
//    self.view.bounds.size.height)
//    ];
//    mapView.showsUserLocation = YES;
//    mapView.mapType = MKMapTypeHybrid;
//    mapView.delegate = self;
//    [self.view addSubview:mapView];
//    }
//    Updated delegate method
//    
//    - (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.005;
//    span.longitudeDelta = 0.005;
//    CLLocationCoordinate2D location;
//    location.latitude = aUserLocation.coordinate.latitude;
//    location.longitude = aUserLocation.coordinate.longitude;
//    region.span = span;
//    region.center = location;
//    [aMapView setRegion:region animated:YES];
//    }
}