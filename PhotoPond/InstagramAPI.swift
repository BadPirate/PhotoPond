//
//  InstagramAPI.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import Foundation
import CoreLocation
import OAuthSwift

class IGImage {
    
}

class InstagramAPI {
    private let oauth : OAuth2Swift
    private var authToken : String?
    private let scope : String
    private let callbackURL : URL
    
    public var viewController : UIViewController? {
        didSet {
            if let vc = self.viewController {
                oauth.authorizeURLHandler = SafariURLHandler(viewController: vc, oauthSwift: oauth)
            }
        }
    }
    
    required init(client: String, secret: String, scope: String, callbackURL: URL) {
        self.oauth = OAuth2Swift(
            consumerKey:    client,
            consumerSecret: secret,
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        self.scope = scope
        self.callbackURL = callbackURL
    }
    
    private func accessToken(completion: (String?, Error?) -> Void) {
        if let authToken = self.authToken { completion(authToken,nil) }
        let success : OAuthSwift.TokenSuccessHandler = { credential, response, parameters in
            print(credential.oauthToken)
        }
        let failure : OAuthSwift.FailureHandler = { error in
            print(error.localizedDescription)
        }
        _ = oauth.authorize(
            withCallbackURL: callbackURL,
            scope: "likes+comments", state:"INSTAGRAM",
            success: success,
            failure: failure
        )
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
