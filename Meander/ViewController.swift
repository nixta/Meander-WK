//
//  ViewController.swift
//  Meander
//
//  Created by Nicholas Furness on 6/1/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import UIKit
import WalkKit
import ArcGIS

class ViewController: UIViewController {
    
    var appDelegate: AppDelegate {
        get {
            return UIApplication.sharedApplication().app_delegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startWalkClicked(sender: AnyObject) {
        appDelegate.startWalk(120) {
            isNewWalk, walk in
            if isNewWalk {
                println("New walk created")
            } else {
                // TODO Show an alert...
                println("Walk already in progress")
            }
        }
    }

}

