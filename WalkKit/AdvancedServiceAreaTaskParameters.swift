//
//  AdvancedServiceAreaTaskParameters.swift
//  Meander
//
//  Created by Nicholas Furness on 6/4/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import Foundation
import ArcGIS

private let travelModeKey = "travelMode"

enum ServiceAreaTravelMode {
    case WalkingTime
    case WalkingDistance
    case DrivingTime
    case DrivingDistance
    case TruckingTime
    case TruckingDistance
}

private var travelModeIDMapping: [ServiceAreaTravelMode : Int] = [
    .DrivingTime: 1,
    .DrivingDistance: 2,
    .TruckingTime: 3,
    .TruckingDistance: 4,
    .WalkingTime: 5,
    .WalkingDistance: 6
]

class AdvancedServiceAreaTaskParameters: AGSServiceAreaTaskParameters {
    var travelMode: ServiceAreaTravelMode = .DrivingTime

    override func encodeToJSON() -> [NSObject : AnyObject]! {
        var d = NSMutableDictionary(dictionary: super.encodeToJSON())
        d[travelModeKey] = travelModeIDMapping[travelMode]
        return d as [NSObject: AnyObject]
    }
}