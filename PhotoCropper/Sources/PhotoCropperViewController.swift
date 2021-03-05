//
//  ImageCropperViewController.swift
//  PhotoCropper
//
//  Created by Edmund Feng on 2021/3/2.
//

import UIKit

public protocol PhotoCropperDelegate: class {
    func didCrop(image: UIImage)
}

public class PhotoCropperViewController: UIViewController {
    //Things you can config
    public weak var delegate: PhotoCropperDelegate!
    public var leftButtonText: String = "Cancel"
    public var rightButtonText: String = "Done"
    public var canCropHint = "框选想要的图片区域"
    public var hasCropperHint = "重新框选或点击完成"
    
    
    enum Mode {
        case camera, crop
    }

    public static func instance() -> PhotoCropperViewController {
        let vc = UIStoryboard(name: "PhotoCropper", bundle: nil).instantiateInitialViewController()! as! PhotoCropperViewController
        return vc
    }

    func configAfterInit() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        mode = .crop
    }

    var image: UIImage?

    @IBOutlet var cropperView: UIView!
    @IBOutlet var controlView: UIView!

    @IBOutlet var snap: UIButton!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var hint: UILabel!
    @IBOutlet var imageView: UIImageView!

    var sideButtons: [UIButton] {
        [leftButton, rightButton]
    }

    var mode: Mode!

    public override func viewDidLoad() {
        super.viewDidLoad()

        leftButton.setTitle(leftButtonText, for: .normal)
        rightButton.setTitle(rightButtonText, for: .normal)
        
        sideButtons.forEach {
            $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
            $0.layer.cornerRadius = 8
            $0.layer.cornerCurve = .continuous
        }

        if case .camera = mode {
            initCameraControlView()

            // add camera view
        } else {
            initCropModeControlView()
            hint.text = canCropHint
            // config imageView
            imageView.image = image

            // addGestureRecoginzer
            cropperView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(selectingImage(sender:))))
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    fileprivate func initCropModeControlView() {
        snap.isHidden = true
        leftButton.setTitle("Cancel", for: .normal)
        rightButton.setTitle("Done", for: .normal)
    }

    fileprivate func initCameraControlView() {
        snap.isHidden = false
        leftButton.setTitle("Cancel", for: .normal)
        rightButton.setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .normal)
    }

    // Gestrue

    @objc
    func selectingImage(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: cropperView)

        if sender.state == .began {
            panStartLocation = location
            addCropper(at: location)
        }

        if sender.state == .changed || sender.state == .ended {
            changeCropper(currentPoint: location)
            hint.text = hasCropperHint
        }
    }

    var panStartLocation: CGPoint?
    var cropper: UIView?

    func addCropper(at location: CGPoint) {
        cropper?.removeFromSuperview()
        cropper = nil
        cropper = UIView()

        let cropper = self.cropper!
        cropper.layer.borderWidth = 1.8
        cropper.layer.cornerRadius = 2
        cropper.layer.borderColor = UIColor.red.cgColor
        cropper.frame = CGRect(origin: location, size: CGSize.zero)
        cropperView?.addSubview(cropper)
    }

    func changeCropper(currentPoint: CGPoint) {
        guard let cropper = self.cropper, let startLocation = panStartLocation else { return }
        
        let originX = min(startLocation.x, currentPoint.x)
        let originY = min(startLocation.y, currentPoint.y)
        
        let width = max(currentPoint.x, startLocation.x) - originX
        let height = max(currentPoint.y, startLocation.y) - originY
        
        cropper.frame.origin = CGPoint(x: originX, y: originY)
        cropper.frame.size.width = width < 0 ? 0 : width
        cropper.frame.size.height = height < 0 ? 0 : height
    }

    // MARK: - Action

    @IBAction func cancal() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func done() {
        guard let image = cropImage() else {
            dismiss(animated: true, completion: nil)
            return
        }
        delegate?.didCrop(image: image)
        dismiss(animated: true, completion: nil)
    }

    func cropImage() -> UIImage? {
        guard let croperRect = cropper?.frame else { return nil }
        var rectInImageView = cropperView.convert(croperRect, to: imageView)

        rectInImageView.origin.x -= imageView.contentClippingRect.origin.x
        rectInImageView.origin.y -= imageView.contentClippingRect.origin.y

        let croppedImage = cropImage(imageView.image!, toRect: rectInImageView, from: imageView)
        return croppedImage
    }

    // MARK: - hint


    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, from imageView: UIImageView) -> UIImage? {
        let viewWidth = imageView.frame.width
        let viewHeight = imageView.frame.height

        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                              y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone)
        else {
            return nil
        }

        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}

fileprivate extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width >= image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
