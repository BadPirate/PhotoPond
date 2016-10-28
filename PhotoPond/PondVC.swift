//
//  PondVC.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class PondVC : UIViewController {
    override func viewDidLoad() {
        scan()
    }
    
    func scan() {
        // Get a batch of photos
        let location = CLLocation(latitude: 37.4041091, longitude: -122.0098641) // TODO: User's actual location
        api.photosAtLocation(location: location, completion: { images, error in
            print(images ?? "No images")
        })
    }
}
