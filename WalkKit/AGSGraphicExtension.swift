//
//  AGSGraphicExtension.swift
//  Meander
//
//  Created by Nicholas Furness on 6/4/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import Foundation
import ArcGIS

extension AGSGraphic {
    func attributeAsDoubleForKey(key: String) -> Double? {
        var exists:ObjCBool = false
        let doubleVal = self.attributeAsDoubleForKey("FromBreak", exists: &exists)
        if exists {
            return doubleVal
        }
        return nil
    }
}
