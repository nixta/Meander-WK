//
//  WalkManager.swift
//  Meander
//
//  Created by Nicholas Furness on 6/1/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import Foundation
import ArcGIS

public class WalkManager: NSObject, AGSServiceAreaTaskDelegate {
    
    var serviceAreaTask: AGSServiceAreaTask!
    
    // Use this to associate requests with callback closures so we can
    // use AGSServiceAreaTask with a trailing closure
    var opDictionary: [NSOperation: ([WalkZone]?, NSError?) -> Void] = [:]

    
    public init(serviceAreaTask: AGSServiceAreaTask) {
        super.init()
        
        self.serviceAreaTask = serviceAreaTask
        self.serviceAreaTask.delegate = self
    }

    
    // Create a 2 hour walk
    public func CreateWalk(location: CLLocation, callback: (Walk?, NSError?) -> Void) {
        var newWalk = Walk(startLocation: location, targetDuration: 120*60)
        newWalk.manager = self
        newWalk.loadWalkZones { loaded, error in
            if loaded {
                callback(newWalk, nil)
            } else if let error = error {
                callback(newWalk, error)
            } else {
                println("This should never happen. WalkZones not loaded. No error.")
                callback(newWalk, nil)
            }
        }
    }
    
    
    // Load the zone polygons for the particular walk
    func getWalkZones(walk: Walk, callback: ([WalkZone]?, NSError?) -> Void) {
        let params = AdvancedServiceAreaTaskParameters()
        params.travelMode = .WalkingTime
        params.defaultBreaks = walk.walkZoneTimes
        params.splitPolygonsAtBreaks = true
        let startFacilities = [AGSGraphic(geometry: AGSPoint(location: walk.startLocation),
            symbol: nil,
            attributes: nil)]
        params.setFacilitiesWithFeatures(startFacilities)
        let op = serviceAreaTask.solveServiceAreaWithParameters(params)
        opDictionary[op] = callback
    }
    
    
    // Handle the ServiceAreaTask response
    public func serviceAreaTask(serviceAreaTask: AGSServiceAreaTask!, operation op: NSOperation!, didSolveServiceAreaWithResult serviceAreaTaskResult: AGSServiceAreaTaskResult!) {
        if let callback = opDictionary[op] {
            opDictionary.removeValueForKey(op)

//            
//            var walkZones: [WalkZone]?
//            
//            if let polygons = serviceAreaTaskResult.serviceAreaPolygons as? [AGSGraphic] {
//                // TODO - Figure out how to use map() here.
//                walkZones = polygons.map { WalkZone(walkZoneGraphic: $0) }
//            }

//            let polygons = serviceAreaTaskResult.serviceAreaPolygons as! [AGSGraphic]
            // TODO - Figure out how to use map() here.
            var walkZones:[WalkZone] = (serviceAreaTaskResult.serviceAreaPolygons as! [AGSGraphic]).map { WalkZone(walkZoneGraphic: $0) }
//            for polygon:AGSGraphic in polygons { // EXC_BAD_INSTRUCTION: fatal error: NSArray element failed to match the Swift Array Element type
//                let p = polygon
//                walkZones.append(WalkZone(walkZoneGraphic: p))
//            }
            
            callback(walkZones, nil)
        } else {
            println("Got a solution from Walk Time but could not find the caller!")
        }
    }
    
    public func serviceAreaTask(serviceAreaTask: AGSServiceAreaTask!, operation op: NSOperation!, didFailSolveWithError error: NSError!) {
        if let callback = opDictionary[op] {
            opDictionary.removeValueForKey(op)
            callback(nil, error)
        } else {
            println("Got an error from Walk Time but could not find the caller! \(error.localizedDescription)")
        }
    }
}