//
//  ViewController.swift
//  MeMe Project
//
//  Created by Ademola Fadumo on 13/04/2023.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Delegates
    
    var memeTextFieldDelegate: MemeTextFieldDelegate!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraTabItem: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    // MARK: Initial setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeDelegates()
        self.setTextFieldDelegates()
        self.setTextFieldAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable camera button if not available
        self.cameraTabItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        self.setupKeyboardNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardNotifier()
    }
    
    func initializeDelegates() {
        self.memeTextFieldDelegate = MemeTextFieldDelegate()
    }
    
    // MARK: UI configuration
    
    func setTextFieldDelegates() {
        self.topTextField.delegate = self.memeTextFieldDelegate
        self.bottomTextField.delegate = self.memeTextFieldDelegate
    }
    
    func setTextFieldAttributes() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let memeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -3.0,
        ]
        
        self.topTextField.defaultTextAttributes = memeTextAttributes
        self.bottomTextField.defaultTextAttributes = memeTextAttributes
        
    }
    
    // MARK: Hide keyboard setup
    
    func setupKeyboardNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifier() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if (bottomTextField.isEditing) {
            self.view.frame.origin.y = -self.getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if (bottomTextField.isEditing) {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: IBActions
    
    @IBAction func albumTabItemPressed(_ sender: UIBarButtonItem) {
        initializeImagePickerController(sourceType: .photoLibrary)
    }
    
    @IBAction func cameraTabItemPressed(_ sender: UIBarButtonItem) {
        initializeImagePickerController(sourceType: .camera)
    }
    
    @IBAction func shareTabItemPressed(_ sender: UIBarButtonItem) {
        let meme = self.createMeme()
        
        if let meme = meme {
            // set up activity view controller
            let activityViewController = UIActivityViewController(activityItems: [ meme.memedImage! ], applicationActivities: nil)
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTabItemPressed(_ sender: UIBarButtonItem) {
        self.memeImageView.image = UIImage()
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    
    // MARK: Private methods
    
    private func initializeImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
        self.present(imagePickerController, animated: true)
    }
    
    // We construct a meme object that contains the top & bottom texts, original
    // image and the memed image.
    private func createMeme() -> Meme? {
        if let image = self.memeImageView.image {
            // Create the meme
            return Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: image, memedImage: generateMemedImage())
        }
        
        return nil
    }
    
    // This method is responsible for grabbing the current frame as an image
    // We hide the toolbars to avoid them showing in the screen grab
    private func generateMemedImage() -> UIImage {
        self.topToolBar.isHidden = true
        self.bottomToolBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.topToolBar.isHidden = false
        self.bottomToolBar.isHidden = false
        
        return memedImage
    }
    
    // MARK: Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            self.memeImageView.image = image
        }
        
        self.dismiss(animated: true)
    }
}
