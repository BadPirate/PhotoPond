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
            
            /*  Access Token discovery works, but my App is Sandboxed, and there are no pictures on any of my sandboxed accounts near any location that is useful.  Additionally, accessing public data is not a valid use case for the Instagram API (WTF?) so you will never be able to unsandbox an app with this functionality.  Fortunately there is a workaround: http://services.chrisriversdesign.com/instagram-token/ -- Has an already approved, non-sandboxed API
                that provides access tokens.   For now, I'm using one of those. */
            
            let accessToken = "4095606396.e029fea.ee3dc1ee12394681874e78a9007fd126"
            
            // let accessToken = accessToken!
                if let error = error { completion(nil,error); return }
                // TODO: Parse out the images
            })
            
        }
    }
    
    private func sendRequest(request: String, completion: (Dictionary<String,AnyObject>?, Error?) -> Void) {
        
    }
}
