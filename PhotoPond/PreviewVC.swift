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
            likeButton?.setImage(UIImage(named: photo.liked ? "777-thumbs-up-selected" : "777-thumbs-up"), for: .normal)
            liked = photo.liked
        }
    }
    
    var photo : IGImage? {
        didSet {
            updatePhoto()
        }
    }
    
    @IBAction func like() {
        if liked { return }
    }
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(sender:)))
        self.imageView!.addGestureRecognizer(tap)
        updateImage()
        updatePhoto()
    }
    
    func dismiss(sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
