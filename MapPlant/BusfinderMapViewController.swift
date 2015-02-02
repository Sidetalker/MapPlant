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
    
    // Logger
    let logger = Swell.getLogger("BusfinderMapViewController")
    
    override func viewDidLoad() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.delegate = self
        
        self.view.addSubview(mapView)
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2)
            }, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
