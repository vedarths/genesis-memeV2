//
//  ViewController.swift
//  MyVMeme
//
//  Created by Vedarth Solutions on 4/18/18.
//  Copyright © 2018 Vedarth Solutions. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    //outlets
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var galleryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    
    @IBOutlet weak var topTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldTopSpace: NSLayoutConstraint!

    let memeTextAttributes:[String: Any] = [
        NSAttributedString.Key.strokeColor.rawValue: UIColor.black /* TODO: fill in appropriate UIColor */,
        NSAttributedString.Key.foregroundColor.rawValue: UIColor.white/* TODO: fill in appropriate UIColor */,
        NSAttributedString.Key.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth.rawValue: -3.5/* TODO: fill in appropriate Float */]
    
    private let defaultTopText = "TOP"
    private let defaultBottomText = "BOTTOM"
    private var chosenText: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        setupDefaults()
    }
    @IBAction func pickFromGallery(_ sender: Any) {
        presentAnImageWithSourceType(sourceType: UIImagePickerController.SourceType.photoLibrary)
    }
    
    @IBAction func pickFromCamera(_ sender: Any) {
        presentAnImageWithSourceType(sourceType: UIImagePickerController.SourceType.camera)
    }
    
    private func presentAnImageWithSourceType(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate=self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupDefaults() -> Void {
        imageView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled=false
        topText.isHidden = true
        bottomText.isHidden = true
        configureTextFields(textField: topText, content: defaultTopText)
        configureTextFields(textField: bottomText, content: defaultBottomText)
    }
    
    private func configureTextFields(textField: UITextField, content: String) -> Void {
        textField.text = content
        textField.delegate = self
        textField.defaultTextAttributes = convertToNSAttributedStringKeyDictionary(memeTextAttributes)
        textField.textAlignment = NSTextAlignment.center
    }
    
    private func clearTextField(textField: UITextField) -> Void {
        textField.clearsOnBeginEditing=true
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow_(_ notification:Notification) {
        if chosenText == bottomText {
            adjustBottomTextPlacing(notification: notification)
        }
    }
    
    private func adjustBottomTextPlacing(notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        //Bottom text field overlaps with keyboard
        if bottomTextFieldTopSpace.constant + bottomText.frame.height >= view.frame.height - keyboardHeight {
            view.frame.origin.y = -((bottomTextFieldTopSpace.constant + bottomText.frame.height) - (view.frame.height - keyboardHeight))
        }
    }
    
    @objc func orientationChanged() {
        repositionTextFields()
    }
    
    @objc func keyboardWillHide_(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        chosenText = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearTextField(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            // looked this code up from google as it was not cleat from the course material!!
            if completed {
                self.save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
      present(activityController, animated: true, completion: nil)
    }
    
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topText.text!,
                        bottomText: bottomText.text!,
                        originalImage: imageView.image!,
                        memedImage: memedImage)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)

    }
    
    private func generateMemedImage() -> UIImage {
        // Render view to an image
        // hide  toolbar and navbar
        topNavigationBar.isHidden = true
        bottomToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        navigationController?.setNavigationBarHidden(false, animated: false)
        topNavigationBar.isHidden = false
        bottomToolbar.isHidden = false
        return memedImage
    }
    
    private func repositionTextFields() {
        let textMargin = CGFloat(20.0)
        let screenCentre =  view.frame.height / 2
        let imageYStartCoordinate = screenCentre - getImageViewCentre()
        let imageYEndCoordinate = screenCentre + getImageViewCentre()
        
        //add a buffer margin to the top text
        let expectedTopTextFieldY = imageYStartCoordinate + textMargin
        // delete buffer margin frmo the bottom text
        let expectedBottomTextFieldY = imageYEndCoordinate - bottomText.frame.height - textMargin
        
        let expectedTopTextFieldYOverlapsWithNavigationBar = expectedTopTextFieldY < topNavigationBar.frame.height
        let expectedBottomTextFieldYOverlapsWithToolbar = expectedBottomTextFieldY + bottomText.frame.height >= bottomText.frame.origin.y
        
        if expectedTopTextFieldYOverlapsWithNavigationBar  {
            topTextFieldTopSpace.constant = topNavigationBar.frame.height + textMargin
        } else {
            topTextFieldTopSpace.constant = expectedTopTextFieldY
        }
        
        if expectedBottomTextFieldYOverlapsWithToolbar {
            bottomTextFieldTopSpace.constant = bottomToolbar.frame.origin.y - bottomText.frame.height - textMargin
        } else {
            bottomTextFieldTopSpace.constant = expectedBottomTextFieldY
        }
    }
    
    private func getImageViewCentre() -> CGFloat {
        return imageView.frame.height / 2
    }
}

extension CreateMemeViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageView.image = image
        dismiss(animated: true, completion: {[weak self] in
            guard let fieldSetters = self else {
                return
            }
            fieldSetters.shareButton.isEnabled = true
            fieldSetters.cancelButton.isEnabled = true
            fieldSetters.topText.isHidden = false
            fieldSetters.bottomText.isHidden = false
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
