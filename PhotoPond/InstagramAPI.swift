//
//  InstagramAPI.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import UIKit
import CoreLocation
import OAuthSwift

class IGImage {
    private var dictionary : Dictionary<String,AnyObject>
    private weak var api : InstagramAPI?
    required init(dictionary: Dictionary<String,AnyObject>, api: InstagramAPI) {
        self.dictionary = dictionary
        self.api = api
    }
    
    public var liked : Bool {
        return (dictionary["user_has_liked"] as? Bool) ?? false
    }
    
    public var thumbnailURL : URL? {
        if let url = thumbnail?["url"] as? String {
            return URL(string: url)
        }
        return nil
    }
    
    public var standardURL : URL? {
        if let url = standard?["url"] as? String {
            return URL(string: url)
        }
        return nil
    }
    
    public var thumbnailWidth : Int {
        if let width = thumbnail?["width"] as? Int {
            return width
        }
        return 0
    }
    
    public var thumbnailHeight : Int {
        if let height = thumbnail?["height"] as? Int {
            return height
        }
        return 0
    }
    
    private var standard : Dictionary<String,AnyObject>? {
        return images?["standard_resolution"]
    }
    
    private var thumbnail : Dictionary<String,AnyObject>? {
        return images?["thumbnail"]
    }
    
    private var images : Dictionary<String,Dictionary<String,AnyObject>>? {
        return dictionary["images"] as? Dictionary<String,Dictionary<String,AnyObject>>
    }
}

class InstagramAPI {
    private let oauth : OAuth2Swift
    private var authToken : String?
    private let scope : String
    private let callbackURL : URL
    
    public var viewController : UIViewController?
    
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
    
    private func accessToken(completion: @escaping (String?, Error?) -> Void) {
        if let authToken = self.authToken { completion(authToken,nil) }
        let success : OAuthSwift.TokenSuccessHandler = { credential, response, parameters in
            self.authToken = credential.oauthToken
            print(self.authToken!)
            completion(self.authToken, nil)
        }
        let failure : OAuthSwift.FailureHandler = { error in
            completion(nil,error)
        }
        let oauthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "oauth") as! OAuthVC
        oauthVC.host = "photopond.herokuapp.com"
        oauthVC.success = { request in
            OAuthSwift.handle(url: request.url!)
        }
        oauth.authorizeURLHandler = oauthVC
        viewController!.present(oauthVC, animated: true, completion: {
            _ = self.oauth.authorize(
                withCallbackURL: self.callbackURL,
                scope: self.scope, state:"INSTAGRAM",
                success: success,
                failure: failure
            )
        })
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
            self.sendRequest(request: "https://api.instagram.com/v1/media/search?lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&distance=5000&access_token=\(accessToken)", completion: { (result, error) in
                if let error = error { completion(nil,error); return }
                if let data = result!["data"] as? [Dictionary<String,AnyObject>] {
                    var images = [IGImage]()
                    for imageDictionary in data {
                        images.append(IGImage(dictionary: imageDictionary, api: self))
                    }
                    completion(images,nil)
                    return
                }
            })
            
        }
    }
    
    private func sendRequest(request: String, completion: @escaping (Dictionary<String,AnyObject>?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: request)!, completionHandler: { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            let object = try! JSONSerialization.jsonObject(with: data!, options: []) // TODO: Should catch
            let dictionary = object as! Dictionary<String,AnyObject> // TODO: Handle other object types?
            completion(dictionary, nil)
        })
        task.resume()
    }
}
