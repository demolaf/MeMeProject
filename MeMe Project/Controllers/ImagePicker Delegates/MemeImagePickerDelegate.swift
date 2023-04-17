//
//  MemeImagePickerDelegate.swift
//  MeMe Project
//
//  Created by Ademola Fadumo on 17/04/2023.
//

import Foundation
import UIKit

class MemeImagePickerDelegate: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let view: UIView!
    let imageView: UIImageView!
    
    init(view: UIView!, imageView: UIImageView!) {
        self.imageView = imageView
        self.view = view
    }
    
    
}
