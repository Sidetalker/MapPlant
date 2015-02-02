//
//  BusfinderMapViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 2/1/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PushSegueNoAnimation: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UIViewController
        if let navigation = source.navigationController {
            navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}

class BusfinderMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    // Map variables
    var mapView = MKMapView()
    var polyline = MKPolyline()
    let lineColor = UIColor.redColor()
    let lineWidth: CGFloat = 2.5
    
    // Location variables
    var locationManager = CLLocationManager()
    var routeLocations = [CLLocationCoordinate2D]()
    
    // Logger
    let logger = Swell.getLogger("BusfinderMapViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateLocations()
        addMap()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2)
            }, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func populateLocations() {
        routeLocations = [CLLocationCoordinate2D]()
        
        let sessions = getObjects(Const.Data.Session, nil) as [Session]
        let curSession = sessions[0]
        let locationSet = curSession.locationSet
        let dataPoints = locationSet.locations
        
        dataPoints.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let location = elem as Location
            let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.lat), longitude: CLLocationDegrees(location.long))
            
            self.routeLocations.append(coord)
        }
    }
    
    func addMap() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.delegate = self
        
        // Gather location info
        var location = CLLocationCoordinate2D(latitude: routeLocations[0].latitude, longitude: routeLocations[0].longitude)
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var region = MKCoordinateRegion(center: location, span: span)
        
        // Zoom to the generated region
        mapView.setRegion(region, animated: true)
        
        polyline = MKPolyline(coordinates: &routeLocations, count: routeLocations.count)
        
        mapView.addOverlay(polyline)
        
        self.view.addSubview(mapView)
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
