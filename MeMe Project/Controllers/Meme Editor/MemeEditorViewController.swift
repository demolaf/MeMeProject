//
//  ViewController.swift
//  MeMe Project
//
//  Created by Ademola Fadumo on 13/04/2023.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
        self.prepareTextField(textField: topTextField, defaultText: "TOP")
        self.prepareTextField(textField: bottomTextField, defaultText: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkIfCameraAvailable()
        
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
    
    func prepareTextField(textField: UITextField, defaultText: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let memeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -3.0,
        ]
        
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self.memeTextFieldDelegate
    }
    
    func checkIfCameraAvailable() {
#if targetEnvironment(simulator)
        cameraTabItem.isEnabled = false;
#else
        cameraTabItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera);
#endif
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
    
    // This method handles the action for both camera and album buttons.
    // An extension on integers to parse sender tag to image picker source type
    // for better readability.
    @IBAction func selectImagePressed(_ sender: UIBarButtonItem) {
        let sourceType = sender.tag.parseIntToSourceType()
        
        initializeImagePickerController(sourceType: sourceType)
    }
    
    @IBAction func shareTabItemPressed(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                self.saveMeme(memedImage: memedImage)
                self.dismiss(animated:true,completion:nil)
            }
        }
        self.present(controller, animated: true, completion: nil)
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
    private func saveMeme(memedImage: UIImage) {
        if let image = self.memeImageView.image {
            // Create the meme
            let meme = Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: image, memedImage: memedImage)
            
            // Add it to the memes array in the Application Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
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
