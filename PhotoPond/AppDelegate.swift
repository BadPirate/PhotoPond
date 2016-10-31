//
//  AppDelegate.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import UIKit
import CWStatusBarNotification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}

let api = InstagramAPI(client: "d761949dd0de4f0d84fbae894401c6f7", secret: "d67120f3a24641fbb8d5561f6ede5145", scope: "likes+public_content", callbackURL: URL(string:  "https://photopond.herokuapp.com")!)

let notification = CWStatusBarNotification()
var notifications = [String]()

public func started(status: String) {
    DispatchQueue.main.async {
        if notifications.count > 0 && notifications.last != status {
            notification.dismiss(completion: {
                notification.display(withMessage: status, completion: nil)
            })
        } else {
            notification.display(withMessage: status, completion: nil)
        }
        notifications.append(status)
        
    }
}

public func finished(status: String) {
    DispatchQueue.main.async {
        if let index = notifications.index(of: status) {
            notifications.remove(at: index)
            if notifications.count == 0 {
                notification.dismiss()
            } else if notifications.last != status {
                notification.dismiss(completion: {
                    notification.display(withMessage: notifications.last, completion: nil)
                })
                
            }
        }
    }
}
