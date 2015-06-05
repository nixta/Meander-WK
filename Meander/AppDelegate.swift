//
//  AppDelegate.swift
//  Meander
//
//  Created by Nicholas Furness on 6/1/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import UIKit
import CoreLocation
import ArcGIS
import WalkKit

let CLAuthStatusNames: [CLAuthorizationStatus: String] = [
    .NotDetermined: "Not Determined",
    .Restricted: "Restricted",
    .Denied: "Denied",
    .AuthorizedAlways: "Always Authorized",
    .AuthorizedWhenInUse: "Authorized When In Use"
]

let serviceAreaURL = NSURL(string: "https://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    var currentWalk: Walk?
    
    var locationAuthorization: CLAuthorizationStatus = .NotDetermined
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        return lm
    }()
    
    lazy var manager: WalkManager = {
        let cred = AGSCredential(user: "", password: "")
        let serviceAreaTask = AGSServiceAreaTask(URL: serviceAreaURL, credential: cred)
        return WalkManager(serviceAreaTask: serviceAreaTask)
    }()
    
    var currentLocation: CLLocation?
    var walkHistory: [Walk] = []
    var visitHistory: [CLVisit] = []

    // If this is not nil, we've been asked for a new Walk and we're waiting
    // for the start location to be returned to us.
    var walkRequestCallback: ((Bool, Walk?) -> Void)?
    
    func startWalk(minutes: UInt, response: (Bool, Walk?) -> Void) {
        if currentWalk != nil {
            response(false, currentWalk)
            return
        }
        
        walkRequestCallback = response

        // Go and get the best location we can right now for the new walk.
        locationManager.startUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("Got authorization status: \(CLAuthStatusNames[status]!)")
        switch status {
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringVisits()
        default:
            if let callback = walkRequestCallback {
                walkRequestCallback = nil
                callback(false, nil)
            }
        }
    }
    
    func locationManager(locationManager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let newLocation = locations.last as? CLLocation
            where newLocation.timestamp.timeIntervalSinceNow < 15 &&
                  newLocation.horizontalAccuracy < 150
        {
            currentLocation = newLocation
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            
            if let callback = walkRequestCallback { // Requested a new walk
                walkRequestCallback = nil
                manager.CreateWalk(newLocation) {
                    walk, error in
                    if let error = error {
                        println("Error creating new Walk: \(error.localizedDescription)")
                        callback(false, walk)
                    } else if let walk = walk {
                        self.currentWalk = walk
                        callback(true, walk)
                    } else {
                        println("This shouldn't happen. No walk and No error")
                        callback(false, walk)
                    }
                }
            } else if var cw = self.currentWalk {
                if cw.addLocation(newLocation) {
                    println("Time to turn around! There are \(cw.timeLeft) seconds left.")
                    // TODO - Raise a notification
                }
                if let currentZone = cw.currentZone {
                    println("Current Zone: \(currentZone.minTime) to \(currentZone.maxTime)")
                    // Update the glance
                }
            }
        } else {
            println("No recent accurate location found")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        visitHistory.append(visit)
        println("Visited: \(visit)")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        println("Requesting authorization")
        
        locationManager.requestAlwaysAuthorization()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension UIApplication {
    var app_delegate: AppDelegate {
        get {
            return UIApplication.sharedApplication().delegate as! AppDelegate
        }
    }
}