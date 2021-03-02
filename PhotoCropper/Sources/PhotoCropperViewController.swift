//
//  ImageCropperViewController.swift
//  PhotoCropper
//
//  Created by Edmund Feng on 2021/3/2.
//

import UIKit

enum Mode {
    case camera, image
}

class PhotoCropperViewController: UIViewController {
    
    func configAfterInit() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @IBOutlet weak var cropperView: UIView!
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var snap: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var mode: Mode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if case .camera = mode {
            snap.isHidden = false
            leftButton.setTitle("Cancel", for: .normal)
            rightButton.setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .normal)
            
            //add camera view
        } else {
            snap.isHidden = true
            leftButton.setTitle("Cancel", for: .normal)
            rightButton.setTitle("Done", for: .normal)
            
            //config imageView
        }
    }
    
    
}
