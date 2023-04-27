//
//  MemeDetailViewController.swift
//  MeMe Project
//
//  Created by Ademola Fadumo on 27/04/2023.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    var meme: Meme!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        memeImageView.image = meme.memedImage
    }
}
