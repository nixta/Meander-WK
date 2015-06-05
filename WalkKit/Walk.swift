//
//  Walk.swift
//  Meander
//
//  Created by Nicholas Furness on 6/1/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import Foundation
import ArcGIS

public enum WalkStatus {
    case NotStarted
    case Walking(WalkZone)
    case Returning(WalkZone)
    case Completed
    
    public var walkZone:WalkZone? {
        switch self {
        case .Walking(let zone):
            return zone
        case .Returning(let zone):
            return zone
        default:
            return nil
        }
    }
}

private let maxWalkDistance = 10
private let walkRangeSize = 5

public struct Walk {
    
    public let startLocation: CLLocation!
    public let startDate: NSDate!
    public let targetDuration: NSTimeInterval!
    
    public var status: WalkStatus = .NotStarted
    public var locationHistory: [CLLocation] = []
    
    var timeExtensions: [NSTimeInterval] = []
    
    public var endDate: NSDate {
        get {
            return startDate.dateByAddingTimeInterval(timeExtensions.reduce(targetDuration, combine: +))
        }
    }
    
    public var timeLeft: NSTimeInterval {
        get {
            return endDate.timeIntervalSinceNow
        }
    }
    
    public var timeToHome: NSTimeInterval {
        get {
            
            return timeLeft
        }
    }
    
    var manager: WalkManager!
    
    var walkZones: [WalkZone] = []
    
    public var currentZone:WalkZone? {
        get {
            return self.status.walkZone
        }
    }
    
    let walkZoneTimes: [UInt] = {
        var times:[UInt] = []
        for i in stride(from: walkRangeSize, through: maxWalkDistance, by: walkRangeSize) {
            times.append(UInt(i))
        }
        return times
    }()
    
    public init(startLocation: CLLocation, targetDuration: NSTimeInterval) {
        self.startLocation = startLocation
        self.startDate = NSDate()
        self.targetDuration = targetDuration
    }
    
    internal mutating func loadWalkZones(response: (Bool, NSError?) -> Void) {
        manager.getWalkZones(self) { walkZones, error in
            if let error = error {
                response(false, error)
            } else if let walkZones = walkZones {
                self.walkZones = walkZones
                response(true, nil)
            } else {
                println("Should not be here. No error and no walk zones")
                response(false, nil)
            }
        }
    }
    
    public mutating func extendWalk(by: NSTimeInterval) {
        timeExtensions.append(by)
    }
    
    private func walkzoneForLocation(location: CLLocation) -> WalkZone? {
        let pt = AGSPoint(location: location)
        for walkZone in walkZones {
            if let walkZonePolygon = walkZone.graphic?.geometry as? AGSPolygon {
                if AGSGeometryEngine().geometry(pt, withinGeometry: walkZonePolygon) {
                    return walkZone
                }
            }
        }
        return nil
    }
    
    public mutating func addLocation(newLocation: CLLocation) -> Bool {
        locationHistory.append(newLocation)

        var oldWalkZone: WalkZone?

        if let newWalkZone = walkzoneForLocation(newLocation) {
            switch status {
            case .NotStarted:
                status = .Walking(newWalkZone)
            case .Walking(let previousWalkZone):
                oldWalkZone = previousWalkZone
                if newWalkZone.maxTime < timeLeft {
                    status = .Returning(newWalkZone)
                    return true
                }
                status = .Walking(newWalkZone)
            case .Returning(let previousWalkZone):
                oldWalkZone = previousWalkZone
                status = .Returning(newWalkZone)
            case .Completed:
                println("This walk is over. Why are we still getting updates? \(newLocation)")
            }
        } else {
            println("Out of range! More than \(maxWalkDistance) minutes from home!")
        }
        
        return false
    }
}