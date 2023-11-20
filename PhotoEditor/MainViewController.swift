//
//  ViewController.swift
//  PhotoEditor
//
//  Created by AAPBD on 18/1/18.
//  Copyright © 2018 Jabstudio. All rights reserved.
//


import UIKit
import CLImageEditor
import GoogleMobileAds

class MainViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLImageEditorDelegate,GADInterstitialDelegate{
    
    //Outlets
    @IBOutlet weak var iconimageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var photoLibraryBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var photoLibraryTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPane: UIView!
    @IBOutlet weak var topPaneTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    //Variables
    var selectedImage:UIImage?
    var editedImage:UIImage?
    
    //Start life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.backgroundImageView.image = UIImage(named: DEFAULT_BACKGROUND_IMAGE)
        navigationController?.navigationBar.barTintColor = UIColor.green
        //UILabel.appearance().font = UIFont(name: "Kokonor", size: 17.0)
      //  animateButtonsToScreen()
        
        if isAdmobEnabled {
            loadAdmobBanner()
        }
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.saveBtn.layer.cornerRadius = 20.0
        self.cancelBtn.layer.cornerRadius = 20.0
        
    }
    
    func animateButtonsToScreen(){
        self.photoLibraryBtn.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.photoLibraryTrailingConstraint.constant = 0
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.cameraTrailingConstraint.constant = 0
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.topPaneTopConstraint.constant = 10
            self.view.layoutIfNeeded()
            
        })
        
        
    }
    
    func animateButtonsOffScreen(){
        self.photoLibraryBtn.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.photoLibraryTrailingConstraint.constant = 225
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.cameraTrailingConstraint.constant = 225
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.topPaneTopConstraint.constant = -200
            self.view.layoutIfNeeded()
            
        })
        
        
    }
    //UIImagePicker Controller Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage?
        print("seletec image size: \(String(describing: selectedImage?.size))")
        
        self.dismiss(animated: true) {
            if self.selectedImage != nil {
                //self.animateButtonsOffScreen()
                self.openCLImageEditor()
            }
        }
    }
    
    func openPhotoLibrary(sender:UIButton){
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){return}
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popoverController = UIPopoverController(contentViewController: imagePicker)
            popoverController.present(from: sender.frame, in: self.view, permittedArrowDirections: .any, animated: true)
        } else {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func openCamera(sender:UIButton){
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){return}
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popoverController = UIPopoverController(contentViewController: imagePicker)
            popoverController.present(from: sender.frame, in: self.view, permittedArrowDirections: .any, animated: true)
        } else {
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    @IBAction func photoLibraryBtnDidTap(_ sender: UIButton) {
        openPhotoLibrary(sender: sender)
    }
    @IBAction func cameraBtnDidTap(_ sender: UIButton) {
        openCamera(sender: sender)
    }
    //Open CL Editor Controller
    func openCLImageEditor(){
        let editor = CLImageEditor(image: self.selectedImage!)
        editor?.delegate = self
        editor?.modalTransitionStyle = .flipHorizontal
        self.present(editor!, animated: true, completion: nil)
        
    }
    //CL Editor Delegates
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        self.dismiss(animated: true) {
           // self.animateButtonsToScreen()
            self.bannerView.isHidden = false
            self.bottomPane.isHidden = true
        }
    }
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        self.dismiss(animated: true) {
            self.bottomPane.isHidden = false
            self.editedImage = image
            self.backgroundImageView.image = image
            self.backgroundImageView.slideInFromLeft()
            self.cameraBtn.isHidden = true
            self.photoLibraryBtn.isHidden = true
            self.iconimageView.isHidden = true
            self.bannerView.isHidden = true
            if isAdmobEnabled {
                self.loadAdmobInterstitial()
            }
        }
    }
    
    @IBAction func cancelBtnDidTap(_ sender: UIButton) {
        self.backgroundImageView.image = UIImage(named: DEFAULT_BACKGROUND_IMAGE)
        self.backgroundImageView.slideInFromBottom()
        self.bottomPane.isHidden = true
        self.editedImage = nil
        
        self.cameraBtn.isHidden = false
        self.photoLibraryBtn.isHidden = false
        self.iconimageView.isHidden = false
        self.bannerView.isHidden = false
        
        
    }
    @IBAction func saveBtnDidTap(_ sender: UIButton) {
        callActivityViewController(sender: sender)
    }
    
    func callActivityViewController(sender:UIButton){
        
        guard let editedImage = self.editedImage else { return }
        let activityController = UIActivityViewController(activityItems: [editedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {
            
            (activity,success,items,error) in
            
            if activity == UIActivityType.saveToCameraRoll {
                if success {
                    
                    let alert = UIAlertController(title: "Success", message: "Image has been saved to photo library", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            let popover = UIPopoverController(contentViewController: activityController)
            popover.present(from: sender.frame, in: self.view, permittedArrowDirections: .any, animated: true)
            
        } else {
            
            self.present(activityController, animated: true, completion: nil)
            
        }
    }
    //ADMOB CODE
    
    //Banner
    @IBOutlet weak var bannerView: GADBannerView!
    func loadAdmobBanner(){
        bannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    //Interstitials
    var interstitial:GADInterstitial?
    func loadAdmobInterstitial(){
        interstitial = GADInterstitial(adUnitID: ADMOB_INTERSTITIALS_UNIT_ID)
        interstitial?.delegate = self
        interstitial?.load(GADRequest())
    }
    //Interstitials Delegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if ad.isReady{
            ad.present(fromRootViewController: self)
        }
    }
    //End App
}


