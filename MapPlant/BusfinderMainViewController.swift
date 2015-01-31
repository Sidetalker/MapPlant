//
//  BusfinderMainViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/31/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class BusfinderMainViewController: UIViewController {
    // UIElements
    var imgHeadshotA: UIImageView!
    var imgHeadshotB: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImages()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addImages() {
        let size = self.view.frame.width / 2
        let frameA = CGRect(x: 0, y: 0, width: size, height: size)
        let frameB = CGRect(x: size, y: 0, width: size, height: size)
    }
}