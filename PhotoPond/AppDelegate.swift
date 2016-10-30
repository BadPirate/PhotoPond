//
//  AppDelegate.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}

let api = InstagramAPI(client: "d761949dd0de4f0d84fbae894401c6f7", secret: "d67120f3a24641fbb8d5561f6ede5145", scope: "likes+public_content", callbackURL: URL(string:  "https://photopond.herokuapp.com")!)
