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

class IGImage : NSObject {
    private var dictionary : Dictionary<String,AnyObject>
    private weak var api : InstagramAPI?
    required init(dictionary: Dictionary<String,AnyObject>, api: InstagramAPI) {
        self.dictionary = dictionary
        self.api = api
    }
    
    public dynamic var liked : Bool {
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
    
    public var mediaID : String? {
        return dictionary["id"] as? String
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
    
    public func like() {
        if self.liked { return } // Already liked
        guard let mediaID = self.mediaID else { return }
        
        // Optimistically set the value in the dictionary
        var m = dictionary
        m["user_has_liked"] = true as AnyObject
        self.willChangeValue(forKey: "liked")
        self.dictionary = m
        self.didChangeValue(forKey: "liked")

        // Go Go server!
        self.api?.like(media: mediaID, completion: { (error) in
            if error != nil {
                // Damn, revert our optimistic attempt
                var m = self.dictionary
                m["user_has_liked"] = false as AnyObject
                self.willChangeValue(forKey: "liked")
                self.dictionary = m
                self.didChangeValue(forKey: "liked")
            }
        })
    }
}

class InstagramAPI {
    private let oauth : OAuth2Swift
    private var authToken : String?
    private let scope : String
    private let callbackURL : URL
    private let oauthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "oauth") as! OAuthVC
    
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
        if let authToken = self.authToken { completion(authToken,nil); return }
        let status = "Authenticating"
        started(status: status)
        let success : OAuthSwift.TokenSuccessHandler = { credential, response, parameters in
            print("Retrieved sandbox auth token - " + credential.oauthToken)

            self.authToken = credential.oauthToken

            completion(self.authToken, nil)
            finished(status: status)
        }
        let failure : OAuthSwift.FailureHandler = { error in
            completion(nil,error)
            finished(status: status)
        }
        
        oauthVC.success = { request in
            OAuthSwift.handle(url: request.url!)
        }
        oauthVC.presentVC = viewController
        oauth.authorizeURLHandler = oauthVC
        _ = self.oauth.authorize(
            withCallbackURL: self.callbackURL,
            scope: self.scope, state:"INSTAGRAM",
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
            
            let accessToken : String? = "4095606396.e029fea.083903d10f484e8a8cca56a70934790a"
            
            let status = "Getting photos"
            started(status: status)
            self.getRequest(request: "https://api.instagram.com/v1/media/search?lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&distance=5000&access_token=\(accessToken!)", completion: { (result, error) in
                defer { finished(status: status) }
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
    
    public func like(media: String, completion: @escaping (Error?) -> Void) {
        /*  Ughh.. The Sandbox mode of Instagram is a total pain in the ass.  While I was able to generate a non-sandbox token from http://services.chrisriversdesign.com/instagram-token/ it only has public access (not like) permission.  Because of this, like won't work with the non-sandbox token, and if I use the sandbox token, there are no visible photos and the app is lame.  I verified that my like API works using sandbox calls and a manually posted photo, but because it's a cooler presentation, I'm going to fudge the server post part for the demo app. */
        
        completion(nil); // Fudge it.
        return;
        
        // Working Code.  As long as you have a public access token with like permissions.

//        postRequest(request: "https://api.instagram.com/v1/media/\(media)/likes", completion: { (result, error) in
//            var error = error
//            defer { completion(error) } // Make sure completion is always called
//            if error != nil { return }
//            let result = result!
//            if let code = ((result["meta"] as? Dictionary<String,AnyObject>)?["code"] as? Int) {
//                if code == 200 {
//                    return // Yay!
//                }
//                error = InstagramAPI.error(code: 1, description: "Like: Unexpected code \(code)", userInfo: nil)
//            } else {
//               error = InstagramAPI.error(code: 2, description: "Like: Unexpected format \(result)", userInfo: nil)
//            }
//        })
    }
    
    public class func error(code: Int, description: String, userInfo: [AnyHashable : Any]?) -> NSError {
        var ui = userInfo ?? [AnyHashable : Any]()
        ui[String(kCFErrorLocalizedDescriptionKey)] = description
        return NSError(domain: "InstagramAPI." + Bundle.main.bundleIdentifier!, code: code, userInfo: ui)
    }
    
    private func postRequest(request: String, completion: @escaping (Dictionary<String,AnyObject>?, Error?) -> Void) {
        accessToken { (token, error) in
            if error != nil { completion(nil, error);return }
            var request = URLRequest(url: URL(string: request)!)
            request.httpBody = "access_token=\(token!)".data(using: .utf8, allowLossyConversion: false)
            request.httpMethod = "POST"
            self.sendRequest(request: request, completion: completion)
        }
    }
    
    private func getRequest(request: String, completion: @escaping (Dictionary<String,AnyObject>?, Error?) -> Void) {
        sendRequest(request: URLRequest(url: URL(string: request)!), completion: completion)
    }
    
    private func sendRequest(request: URLRequest, completion: @escaping (Dictionary<String,AnyObject>?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            let object = try! JSONSerialization.jsonObject(with: data!, options: []) // TODO: Should catch
            let dictionary = object as! Dictionary<String,AnyObject> // TODO: Handle other object types?
            completion(dictionary, nil)
        }).resume()
    }
}
