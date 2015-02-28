//
//  BusfinderLoginViewController.swift
//  MapPlant
//
//  Created by Kevin Sullivan on 1/31/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import Foundation
import UIKit

class BusfinderLoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    // Dynamically created UI elements
    var blurView: UIVisualEffectView?
    var titleLabel: UILabel?
    var usernameField: UITextField?
    var passwordField: UITextField?
    var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Add all of the custom UI elements
        addBlur()
        addTitle()
        addFields()
        addButton()
        
        self.view.bringSubviewToFront(imgLogo)
        
        // Smoothly animate our UI elements
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.blurView!.alpha = 0.9
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.titleLabel!.alpha = 0.8
            self.passwordField!.alpha = 0.8
            self.usernameField!.alpha = 0.8
            self.loginButton!.alpha = 0.8
            }, completion: { Bool in
                self.titleLabel!.alpha = 1.0
        })
        
        UIView.animateWithDuration(1.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.imgLogo.alpha = 1
            }, completion: nil)
        
        let tapLogo = UITapGestureRecognizer(target: self, action: "tapLogo:")
        imgLogo.addGestureRecognizer(tapLogo)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Const.Segue.BusfinderMainScreen {
            // Get handles on the navigation controller and embedded chat list controller
            let mainVC = segue.destinationViewController as BusfinderMainViewController
        }
    }
    
    // Generate the view controlling the background blur effect
    func addBlur() {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurView = UIVisualEffectView(effect: blur)
        
        blurView!.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        blurView!.alpha = 0.0
        
        self.view.addSubview(blurView!)
    }
    
    // Create the title text label
    func addTitle() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 130))
        
        titleLabel!.text = "Busfinder"
        titleLabel!.font = UIFont(name: "Damascus", size: 48)
        titleLabel!.textColor = UIColor.whiteColor()
        titleLabel!.textAlignment = NSTextAlignment.Center
        titleLabel!.alpha = 0.0
        
        self.view.addSubview(titleLabel!)
    }
    
    // Create the username and password fields
    func addFields() {
        usernameField = getField(CGRect(x: 50, y: 103, width: self.view.frame.width - 100, height: 30), placeholder: "Username")
        passwordField = getField(CGRect(x: 50, y: 145, width: self.view.frame.width - 100, height: 30), placeholder: "Password")
        
        usernameField?.returnKeyType = UIReturnKeyType.Next
        passwordField?.returnKeyType = UIReturnKeyType.Done
        usernameField?.alpha = 0.0
        passwordField?.alpha = 0.0
        passwordField?.secureTextEntry = true
        
        self.view.addSubview(usernameField!)
        self.view.addSubview(passwordField!)
    }
    
    // Create the login button
    func addButton() {
        loginButton = UIButton(frame: CGRect(x: 50, y: 192, width: self.view.frame.width - 100, height: 50))
        loginButton?.setAttributedTitle(NSAttributedString(string: "Log On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-Light", size: 23)!))), forState: UIControlState.Normal)
        loginButton?.setAttributedTitle(NSAttributedString(string: "Log On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.lightGrayColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-Light", size: 23)!))), forState: UIControlState.Highlighted)
        loginButton?.alpha = 0.0
        loginButton?.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton?.addTarget(self, action: "smoothAnim", forControlEvents: UIControlEvents.TouchDown)
        loginButton?.addTarget(self, action: "smoothAnimUndo", forControlEvents: UIControlEvents.TouchUpOutside)
        
        self.view.addSubview(loginButton!)
    }
    
    // These two functions take care of a tiny graphical inconsistency while fading out the Log On text
    func smoothAnim() {
        loginButton?.setAttributedTitle(NSAttributedString(string: loginButton!.titleLabel!.text!, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.lightGrayColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-Light", size: 23)!))), forState: UIControlState.Normal)
    }
    
    func smoothAnimUndo() {
        loginButton?.setAttributedTitle(NSAttributedString(string: loginButton!.titleLabel!.text!, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-Light", size: 23)!))), forState: UIControlState.Normal)
    }
    
    // Get pretty transparent text fields provided frame and placeholder
    func getField(frame: CGRect, placeholder: String) -> UITextField {
        let textField = UITextField(frame: frame)
        let placeholderString = NSAttributedString(string: placeholder, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!)))
        
        textField.attributedPlaceholder = placeholderString
        textField.font = UIFont(name: "HelveticaNeue", size: 14)
        textField.tintColor = UIColor.whiteColor()
        textField.textColor = UIColor.whiteColor()
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        textField.layer.borderWidth = 0.6
        textField.layer.cornerRadius = 7
        textField.clipsToBounds = true
        textField.alpha = 0.8
        textField.delegate = self
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.autocorrectionType = UITextAutocorrectionType.No
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = UITextFieldViewMode.Always
        
        let clearButton: UIButton = textField.valueForKey("_clearButton") as UIButton
        clearButton.setImage(UIImage(named: Const.Image.ClearButton), forState: UIControlState.Normal)
        clearButton.setImage(UIImage(named: Const.Image.ClearButtonPressed), forState: UIControlState.Highlighted)
        
        return textField
    }
    
    func dismissKeyboard() {
        usernameField?.resignFirstResponder()
        passwordField?.resignFirstResponder()
    }
    
    func login() {
        // Hide the keyboard
        dismissKeyboard()
        
        self.performSegueWithIdentifier(Const.Segue.BusfinderMainScreen, sender: self)
    }
    
    func tapLogo(sender: UIImageView) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}