//
//  PreviewVC.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/30/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import Foundation
import UIKit

class PreviewVC : UIViewController {
    @IBOutlet var imageView : UIImageView?
    @IBOutlet var likeButton : UIButton?
    
    var liked = false
    
    var image : UIImage? {
        didSet {
            updateImage()
        }
    }
    
    func updateImage()
    {
        imageView?.image = image
    }
    
    func updatePhoto() {
        if let photo = photo {
            liked = photo.liked
            DispatchQueue.main.async {
                self.likeButton?.setImage(UIImage(named: photo.liked ? "777-thumbs-up-selected" : "777-thumbs-up"), for: .normal)
            }
        }
    }
    
    var photo : IGImage? {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeObserver(self, forKeyPath: "liked")
            }
            if let photo = photo {
                photo.addObserver(self, forKeyPath: "liked", options: [.initial, .new], context: nil)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "liked" {
            updatePhoto()
        }
    }
    
    @IBAction func like() {
        if liked { return }
        liked = true
        photo?.like()
    }
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(sender:)))
        self.imageView!.addGestureRecognizer(tap)
        updateImage()
        updatePhoto()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        api.viewController = self
    }
    
    func dismiss(sender: UITapGestureRecognizer) {
        photo = nil // Clear KVO
        dismiss(animated: true, completion: nil)
    }
}
