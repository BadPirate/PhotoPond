//
//  InstagramAPI.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import Foundation
import CoreLocation

class IGImage {
    
}

class InstagramAPI {
    private let client : String
    private let secret : String
    
    required init(client: String, secret: String) {
        // Note: If we were worried about hackers, this information should be encrypted in the source.
        self.client = client
        self.secret = secret
    }
    
    private func accessToken(completion: (String?, Error?) -> Void) {
        
    }
    
    public func photosAtLocation(location: CLLocation, completion: @escaping ([IGImage]?, Error?) -> Void) {
        accessToken { (accessToken, error) in
            if let error = error {
                completion(nil,error)
                return
            }
            let accessToken = accessToken!
            sendRequest(request: "https://api.instagram.com/v1/media/search?lat=48.858844&lng=2.294351&access_token="+accessToken, completion: { (result, error) in
                if let error = error { completion(nil,error); return }
                // TODO: Parse out the images
            })
            
        }
    }
    
    private func sendRequest(request: String, completion: (Dictionary<String,AnyObject>?, Error?) -> Void) {
        
    }
}
