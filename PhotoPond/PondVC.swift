//
//  PondVC.swift
//  PhotoPond
//
//  Created by Kevin Lohman on 10/28/16.
//  Copyright © 2016 Logic High. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreFoundation

class LilyView : UIImageView {
    public var photo : IGImage?
    public var loading : Bool = false {
        didSet {
            if loading {
                activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activity!.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
                self.addSubview(activity!)
                activity!.startAnimating()
            } else {
                if let activity = activity {
                    activity.removeFromSuperview()
                    self.activity = nil
                }
            }
        }
    }
    
    private var activity : UIActivityIndicatorView?
}

class PondVC : UIViewController {
    let collider = UICollisionBehavior()
    let gravity = UIGravityBehavior()
    let dynamic = UIDynamicItemBehavior()
    var appeared = false
    var animator : UIDynamicAnimator?
    var previewing = false
    
    override func viewDidLoad() {
        let animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(collider)
        collider.translatesReferenceBoundsIntoBoundary = true
        
        gravity.gravityDirection = CGVector(dx: 0, dy: 0.8)
        animator.addBehavior(gravity);
        
        dynamic.elasticity = 1.0
        animator.addBehavior(dynamic)
        
        self.animator = animator
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if appeared { return }
        appeared = true
        scan()
    }
    
    func scan() {
        // Get a batch of photos
        let location = CLLocation(latitude: 48.8583736, longitude: 2.2922926) // TODO: User's actual location, currently Eiffel Tower
        api.viewController = self
        api.photosAtLocation(location: location, completion: { images, error in
            if let error = error {
                print(error) // TODO: Nice alert or better error handling here.
                return
            }
            for image in images! {
                self.addPhoto(photo: image)
            }
        })
    }
    
    func addPhoto(photo: IGImage) {
        guard let url = photo.thumbnailURL else { print("No photo url - \(photo)"); return }
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            if error != nil { return }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.addImage(image: image, photo: photo)
                }
            }
        }).resume()
    }
    
    var lilySize : Int {
        let coverage : Double = 0.7
        let area : Double = Double(self.view.frame.width * self.view.frame.height)
        return Int(floor(sqrt(area/20)*coverage))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     
        if let touch = touches.first, let touchView = touch.view as? LilyView {
            let currentLocation = touchView.center
            let location = touch.location(in: self.view)
            dynamic.addLinearVelocity(CGPoint(x: location.x - currentLocation.x, y: location.y - currentLocation.y), for: touchView)
        }
    }
    
    func addImage(image : UIImage, photo : IGImage) {
        let lily = LilyView(image: image)
        lily.photo = photo
        let size = lilySize
        lily.frame.size = CGSize(width: size, height: size)
        let randx = Int(arc4random_uniform(UInt32(self.view.frame.size.width-CGFloat(size)))+UInt32(size/2))
        let randy = Int(arc4random_uniform(UInt32(self.view.frame.size.height-CGFloat(size)))+UInt32(size/2))
        lily.center = CGPoint(x: randx, y: randy)
        lily.isUserInteractionEnabled = true
        self.view.addSubview(lily)
        collider.addItem(lily)
        dynamic.addItem(lily)
        let randvx = Int(arc4random_uniform(30))-15
        let randvy = Int(arc4random_uniform(30))-15
        dynamic.addLinearVelocity(CGPoint(x: randvx, y: randvy), for: lily)
        let tap = UITapGestureRecognizer(target: self, action: #selector(PondVC.preview(tap:)))
        lily.addGestureRecognizer(tap)
    }
    
    func preview(tap: UITapGestureRecognizer) {
        if previewing { return }
        if let lily = tap.view as? LilyView, let photo = lily.photo, let url = photo.standardURL {
            previewing = true
            lily.loading = true
            URLSession.shared.downloadTask(with: url, completionHandler: { url, _, _ in
                defer { self.previewing = false; }
                guard let url = url else { return }
                
                // Rename file before using, otherwise it gets deleted before loading.
                let destination = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString)
                try! FileManager.default.moveItem(at: url, to: destination)
                
                if let image = UIImage(contentsOfFile: destination.path) {
                    DispatchQueue.main.sync {
                        let previewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "preview") as! PreviewVC
                        previewVC.image = image
                        previewVC.photo = photo
                        self.present(previewVC, animated: true, completion: nil)
                        lily.loading = false
                    }
                }
            }).resume()
        }
    }
}


