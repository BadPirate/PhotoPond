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
    
    public var success : ((URLRequest) -> Void)?
    public var presentVC : UIViewController?
    
    func handle(_ url: URL) {
        view.tag = 1 // Make sure our view and thus webview is loaded.
        webView!.loadRequest(URLRequest(url: url))
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.fragment?.contains("access_token") == true {
            success!(request)
            dismiss(animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // If we stop on a page before the redirect closes us, user interaction is required.  Present.
        presentVC?.present(self, animated: true, completion: nil)
    }
}
