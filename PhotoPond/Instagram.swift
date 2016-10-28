//
//  Instagram.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import Foundation
import OAuthSwift

class Instagram {
    let oauth : OAuth2Swift
    init(key: String, secret: String, scope: String) {
        oauth = OAuth2Swift(consumerKey: key, consumerSecret: secret, authorizeUrl: "https://api.instagram.com/oauth/authorize", responseType: "token")
        oauth.authorize(withCallbackURL: "PhotoPond://oauth-callback/instagram", scope: <#T##String#>, state: <#T##String#>, success: <#T##OAuthSwift.TokenSuccessHandler##OAuthSwift.TokenSuccessHandler##(OAuthSwiftCredential, URLResponse?, OAuthSwift.Parameters) -> Void#>, failure: <#T##OAuthSwift.FailureHandler?##OAuthSwift.FailureHandler?##(OAuthSwiftError) -> Void#>)
    }
}
