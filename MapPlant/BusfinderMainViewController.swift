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
    
    // IB Connections
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.frame = CGRect(x: 0, y: self.view.frame.width / 2, width: self.view.frame.width, height: self.view.frame.height - self.view.frame.width / 2 - imgLogo.frame.height)
    }
    
    override func viewWillAppear(animated: Bool) {
        addImages()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addImages() {
        let size = self.view.frame.width / 2
        let border: CGFloat = 3
        let finalFrameA = CGRect(x: border, y: border, width: size - border * 2, height: size - border * 2)
        let finalFrameB = CGRect(x: size + border, y: border, width: size - border * 2, height: size - border * 2)
        let startFrameA = CGRect(x: size / 2, y: size / 2, width: 0, height: 0)
        let startFrameB = CGRect(x: size + size / 2, y: size / 2, width: 0, height: 0)
        
        imgHeadshotA = UIImageView(frame: startFrameA)
        imgHeadshotB = UIImageView(frame: startFrameB)
        
        imgHeadshotA.image = UIImage(named: Const.Image.HeadshotA)
        imgHeadshotB.image = UIImage(named: Const.Image.HeadshotB)
        imgHeadshotA.userInteractionEnabled = true
        imgHeadshotB.userInteractionEnabled = true
        
        imgHeadshotA.alpha = 1;
        imgHeadshotA.layer.shadowOpacity = 0.8;
        imgHeadshotA.layer.shadowOffset = CGSizeMake(0, 0);
        imgHeadshotA.layer.shadowRadius = 5;
        imgHeadshotA.layer.shadowColor = UIColor.blackColor().CGColor
        
        imgHeadshotB.alpha = 1;
        imgHeadshotB.layer.shadowOpacity = 0.8;
        imgHeadshotB.layer.shadowOffset = CGSizeMake(0, 0);
        imgHeadshotB.layer.shadowRadius = 5;
        imgHeadshotB.layer.shadowColor = UIColor.blackColor().CGColor
        
        // Set vertical effect
        var verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -8
        verticalMotionEffect.maximumRelativeValue = 8
        
        // Set horizontal effect
        var horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -8
        horizontalMotionEffect.maximumRelativeValue = 8
        
        // Create group to combine both
        var group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        imgHeadshotA.addMotionEffect(group)
        imgHeadshotB.addMotionEffect(group)
        
        self.view.addSubview(imgHeadshotA)
        self.view.addSubview(imgHeadshotB)
        
        UIView.animateWithDuration(0.9, delay: 0.2, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgHeadshotA.frame = finalFrameA
            }, completion: nil)
        
        UIView.animateWithDuration(0.9, delay: 0.35, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgHeadshotB.frame = finalFrameB
        }, completion: nil)
    }
}