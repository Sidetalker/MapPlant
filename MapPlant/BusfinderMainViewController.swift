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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addImages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
        // Gesture recognizers
        let tapKidA = UITapGestureRecognizer(target: self, action: "tapKidA:")
        let tapKidB = UITapGestureRecognizer(target: self, action: "tapKidB:")
        
        imgHeadshotA.addGestureRecognizer(tapKidA)
        imgHeadshotB.addGestureRecognizer(tapKidB)
        
        self.view.addSubview(imgHeadshotA)
        self.view.addSubview(imgHeadshotB)
        
        UIView.animateWithDuration(0.9, delay: 0.2, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgHeadshotA.frame = finalFrameA
            }, completion: nil)
        
        UIView.animateWithDuration(0.9, delay: 0.35, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.imgHeadshotB.frame = finalFrameB
        }, completion: nil)
    }
    
    func tapKidA(sender: UIImageView) {
        // logger.debug("KidA done got tapped")
        
        transition(0)
    }
    
    func tapKidB(sender: UIImageView) {
        // logger.debug("KidB done got tapped")
        
        transition(1)
    }
    
    func transition(tapped: Int) {
        let size = self.view.frame.width / 2
        let newFrameA = CGRect(x: size / 2, y: size / 2, width: 0, height: 0)
        let newFrameB = CGRect(x: size + size / 2, y: size / 2, width: 0, height: 0)
        
        if tapped == 0 {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.imgHeadshotA.frame = newFrameA
                }, completion: nil)
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.imgHeadshotB.frame = newFrameB
                }, completion: nil)
        }
        else {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.imgHeadshotB.frame = newFrameB
                }, completion: nil)
            
            UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.imgHeadshotA.frame = newFrameA
                }, completion: nil)
        }
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: {
            self.container.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
            }, completion: { Bool in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let mapView = storyboard.instantiateViewControllerWithIdentifier(Const.View.BusfinderMapScreen) as BusfinderMapViewController
                self.presentViewController(mapView, animated: false, completion: nil)
            })
    }
}