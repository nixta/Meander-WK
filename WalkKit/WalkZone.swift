//
//  WalkZone.swift
//  Meander
//
//  Created by Nicholas Furness on 6/4/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import Foundation
import ArcGIS

public struct WalkZone {
    public var minTime: NSTimeInterval = 0
    public var maxTime: NSTimeInterval = 5 * 60
    var graphic: AGSGraphic!
    
    init(walkZoneGraphic: AGSGraphic) {
        graphic = walkZoneGraphic
        if let fromBreak = walkZoneGraphic.attributeAsDoubleForKey("FromBreak"),
               toBreak = walkZoneGraphic.attributeAsDoubleForKey("ToBreak") {
            minTime = fromBreak * 60
            maxTime = toBreak * 60
        }
    }
}
