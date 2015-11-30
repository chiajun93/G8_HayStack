//
//  LocationAcquisitionViewController.swift
//  HayStack
//
//  Created by Ian McDowell on 9/24/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import CoreLocation

class LocationAcquisitionViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        self.checkAuthorizationStatus()
        
        
    }
    
    func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            manager.startUpdatingLocation()
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'When in use'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.checkAuthorizationStatus()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
        if (lastLocation.timestamp.timeIntervalSinceNow > -10) {
            manager.stopUpdatingLocation()
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.myLocation = lastLocation
            
            HSAPILoader.getUser(){ (success, error) -> Void in
                if(success){
                    appDelegate.showMainPage()
                }else{
                    appDelegate.showLoginPage()
                }
            }
        }
    }
}
