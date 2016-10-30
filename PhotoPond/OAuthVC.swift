//
//  oauthvc.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import UIKit
import OAuthSwift

class OAuthVC : UIViewController, OAuthSwiftURLHandlerType, UIWebViewDelegate {
    @IBOutlet var webView : UIWebView?
    
    public var host : String?
    public var success : ((URLRequest) -> Void)?
    
    func handle(_ url: URL) {
        webView!.loadRequest(URLRequest(url: url))
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.host?.contains(host!) == true {
            success!(request)
            dismiss(animated: true, completion: nil)
            return false
        }
        return true
    }
}
