//
//  CryptoExtensions.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 10.02.18.
//  Copyright © 2018 Vlad Getman. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

extension UIImage {
    public func toMediaData(quality: CGFloat = 0.9) -> MediaData {
        let data = jpegData(compressionQuality: quality)!
        let hash = data.md5()
        let name = hash.hexString() + ".jpg"
        let mediaData = MediaData(data: data, name: name, contentType: "image/jpg")
        return mediaData
    }
}

extension Data {
    public func toMediaData(_ contentType: String, fileExtension: String) -> MediaData {
        let hash = md5()
        let name = hash.hexString() + "." + fileExtension
        let mediaData = MediaData(data: self, name: name, contentType: contentType)
        return mediaData
    }
}

extension Data {
    func hexString() -> String {
        let nsdataStr = NSData(data: self)
        return nsdataStr.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
    }
}
