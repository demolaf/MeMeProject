//
//  TagToImagePickerSourceType.swift
//  MeMe Project
//
//  Created by Ademola Fadumo on 17/04/2023.
//

import Foundation
import UIKit

// Extension on Integer for sender tag e.g. 0, 1 to Image picker source type
// to improve readability
extension Int {
    func parseIntToSourceType() -> UIImagePickerController.SourceType {
        switch self {
        case 0:
            return .camera
        case 1:
            return .photoLibrary
        default:
            return .photoLibrary
        }
    }
}
