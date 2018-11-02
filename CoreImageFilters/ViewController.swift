//
//  ViewController.swift
//  CoreImageFilters
//
//  Created by Onur Işık on 2.11.2018.
//  Copyright © 2018 Onur Işık. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var xCoord: CGFloat = 5
    let yCoord: CGFloat = 5
    let buttonWidth: CGFloat = 70
    let buttonHeight: CGFloat = 70
    let gapBetweenButtons: CGFloat = 5
    
    var filterName: String!
    var centerVector: CIVector!
    var scaleFactor: CGFloat!
    var editingImage: UIImage!
    var tempFilter: CIFilter!
    var panGesture: UIPanGestureRecognizer!
    let imagePicker = UIImagePickerController()
    var filterList: [String] = [
        "CIColorCubeWithColorSpace", "CIColorInvert", "CIColorMonochrome", "CIColorPosterize",
        "CIFalseColor", "CIMaximumComponent", "CIMinimumComponent", "CIPhotoEffectChrome", "CIPhotoEffectFade",
        "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer",
        "CISepiaTone", "CIVignette", "CIVignetteEffect", "CITorusLensDistortion", "CITwirlDistortion", "CIVortexDistortion",
        "CIGaussianBlur", "CIMotionBlur", "CIZoomBlur"
    ]

    let volatileFiltersName: [String] = [
        "CIVortexDistortion", "CITorusLensDistortion", "CITwirlDistortion", "CIGaussianBlur", "CIMotionBlur", "CIZoomBlur", "CIVignetteEffect"
    ]

    var indicator = UIActivityIndicatorView(style: .whiteLarge)
    var orignalImage: UIImage = UIImage(named: "GirlImage")!
    
    @IBOutlet weak var sliderViewLabel: UILabel!
    @IBOutlet weak var sliderViewSlider: UISlider!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var masterImageView: UIImageView!
    @IBOutlet weak var filterScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        masterImageView.layer.masksToBounds = true
        masterImageView.layer.cornerRadius = 5.0
        masterImageView.layer.borderWidth = 3.0
        masterImageView.layer.borderColor = UIColor.lightGray.cgColor
        editingImage = self.masterImageView.image!
        centerVector = CIVector(x: self.editingImage.size.width/2, y: self.editingImage.size.height/2)
        
        self.view.addSubview(indicator)
        indicator.center = self.view.center
        self.indicator.startAnimating()
        
        self.addFilters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sliderView.isHidden = true
    }
    
    fileprivate func addFilters() {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            var itemCount = 0
            for index in 0..<self.filterList.count {
                
                itemCount = index
                
                let filterButton = UIButton(type: .custom)
                filterButton.frame = CGRect(x: self.xCoord, y: self.yCoord, width: self.buttonWidth, height: self.buttonHeight)
                filterButton.tag = itemCount
                filterButton.addTarget(self, action: #selector(self.filterTapped(_:)), for: .touchUpInside)
                filterButton.layer.masksToBounds = true
                filterButton.layer.cornerRadius = 5.0
                filterButton.clipsToBounds = true
                
                let filterNameLabel = UILabel(frame: CGRect(x: self.xCoord, y: self.buttonHeight + 4, width: self.buttonWidth, height: 20))
                let filterName = self.filterList[index]
                filterNameLabel.text = filterName
                filterNameLabel.textColor = .black
                filterNameLabel.textAlignment = .center
                filterNameLabel.font = UIFont(name: "Helvetica-Regular", size: 8)
                
                let context = CIContext()
                let filter = CIFilter(name: filterName)
                let coreImage = CIImage(image: self.editingImage)
                filter!.setDefaults()
                
                self.volatileFiltersName.forEach({ (listFilterName) in
                    if filterName == listFilterName {
                        if filterName != "CIGaussianBlur" && filterName != "CIMotionBlur" && filterName != "CIZoomBlur" {
                            filter?.setValue(self.centerVector, forKey: kCIInputCenterKey)
                        }
                    }
                })
                
                filter!.setValue(coreImage, forKey: kCIInputImageKey)
                let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
                let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
                let imageForButton = UIImage(cgImage: filteredImageRef!)
                
                
                DispatchQueue.main.async {
                    
                    
                    filterButton.setBackgroundImage(imageForButton, for: .normal)
                    
                    self.xCoord += self.buttonWidth + self.gapBetweenButtons
                    self.filterScroll.addSubview(filterButton)
                    self.filterScroll.addSubview(filterNameLabel)
                    self.filterScroll.setNeedsDisplay()
                    
                    if itemCount == self.filterList.count - 1 {
                        self.indicator.stopAnimating()
                    }
                    
                }
            }
            
            
            self.filterScroll.contentSize = CGSize(width: self.buttonWidth * CGFloat(itemCount + 3), height: self.yCoord)
        }
        
    }
    
    @objc fileprivate func filterTapped(_ sender: UIButton) {
        
        UIView.transition(with: self.masterImageView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: { self.masterImageView.image = sender.backgroundImage(for: .normal) },
                          completion: nil)
        filterName = filterList[sender.tag]
        
        checkFilterName(name: filterName)
    }
    
    
    fileprivate func checkFilterName(name: String) {
        self.sliderView.isHidden = true
        
        volatileFiltersName.forEach { (filter) in
            
            if filter == name {
                self.sliderView.isHidden = false
                self.tempFilter = CIFilter(name: name)
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UISlider, _ event: UIEvent) {
        
        let value = Int(sender.value)
        
        guard let touch = event.allTouches?.first, touch.phase != .ended else {
            self.indicator.startAnimating()
            
            DispatchQueue.global(qos: .userInteractive).async {
                let tempContext = CIContext()
                self.tempFilter!.setDefaults()
                
                switch self.filterName {
                case "CIZoomBlur":
                    self.tempFilter!.setValue(value, forKey: kCIInputAmountKey)
                    self.tempFilter!.setValue(self.centerVector, forKey: kCIInputCenterKey)
                case  "CITorusLensDistortion":
                    self.tempFilter!.setValue(self.centerVector, forKey: kCIInputCenterKey)
                    self.tempFilter!.setValue(value, forKey: kCIInputWidthKey)
                case "CITwirlDistortion", "CIVortexDistortion", "CIVignetteEffect":
                    self.tempFilter!.setValue((value * 10), forKey: kCIInputRadiusKey)
                    self.tempFilter!.setValue(self.centerVector, forKey: kCIInputCenterKey)
                case "CIGaussianBlur":
                    self.tempFilter!.setValue(value, forKey: kCIInputRadiusKey)
                default:
                    break
                }
                
                
                let coreImage = CIImage(image: self.orignalImage)
                self.tempFilter!.setValue(coreImage, forKey: kCIInputImageKey)
                let filteredImageData = self.tempFilter!.value(forKey: kCIOutputImageKey) as! CIImage
                let filteredImageRef = tempContext.createCGImage(filteredImageData, from: filteredImageData.extent)
                self.editingImage = UIImage(cgImage: filteredImageRef!)
                
                DispatchQueue.main.async {
                    
                    self.indicator.stopAnimating()
                    self.masterImageView.image = self.editingImage
                    
                }
            }
            return
        }
        
        self.sliderViewLabel.text = "\(value)"
        self.sliderViewLabel.layer.position = CGPoint(x: sender.thumbCenterX, y: sliderViewLabel.frame.midY)
        
    }
    
    
    @IBAction func openLibraryPressed(_ sender: UIButton) {
        // Show photo library here
        self.choosePhoto()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        UIImageWriteToSavedPhotosAlbum(masterImageView.image!, nil, nil, nil)
        let alert = UIAlertController(title: "Success 🎉", message: "Your Image saved to photo library successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     * Use this method for open pick an image view
     */
    @objc func choosePhoto() {
        
        // MARK :- Request permitted lets show menu
        let actionSheet = UIAlertController(title: "Choose image source" , message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (_) in
            
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                print("Device camera unusable right now!")
                return
            }
            self.openCamera(pickerObj: self.imagePicker)
        }
        let photoLibrary = UIAlertAction(title: "Photo library", style: .default) { (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                print("Can't open photo library!")
                return
            }
            self.openPhotoLibrary(pickerObj: self.imagePicker)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func openPhotoLibrary(pickerObj: UIImagePickerController) {
        // Instantiates and configures class var
        pickerObj.allowsEditing = false
        pickerObj.sourceType = .photoLibrary
        pickerObj.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        pickerObj.delegate = self
        pickerObj.modalPresentationStyle = .popover
        // Present controller
        self.present(pickerObj, animated: true, completion: nil)
        
    }
    
    /*
     * Use this method for open camera
     */
    fileprivate func openCamera(pickerObj: UIImagePickerController) {
        // Instantiates and configures class var
        pickerObj.sourceType = .camera
        pickerObj.allowsEditing = false
        pickerObj.cameraCaptureMode = .photo
        pickerObj.cameraDevice = .front
        pickerObj.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        pickerObj.delegate = self
        pickerObj.modalPresentationStyle = .currentContext
        
        // Present controller
        self.present(pickerObj, animated: true, completion: nil)
    }
    

    
}

extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            if let pickedImage = info[ .originalImage] as? UIImage {
                
                self.masterImageView.image = pickedImage
                self.editingImage = pickedImage
                self.orignalImage = pickedImage
                
                /* Remove all buttons from scroll view */
                self.filterScroll.subviews.forEach({ (button) in
                    if let currentButton = button as? UIButton {
                        currentButton.removeFromSuperview()
                    }
                })
                /* Reset position counter of buttons */
                self.xCoord = 5
                /* Add buttons with new filtered image */
                self.indicator.startAnimating()
                self.addFilters()
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
}
