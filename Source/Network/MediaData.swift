//
//  MediaData.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

@objc open class MediaData: NSObject {
    
    @objc open let data: Data
    @objc open let name: String
    @objc open let contentType: String
    
    @objc public init(data: Data, name: String, contentType: String) {
        self.data = data
        self.name = name
        self.contentType = contentType
        super.init()
    }
    
    @objc public init(jpegImage: UIImage, quality: CGFloat = 0.9, name: String = "photo.jpg") {
        self.data = jpegImage.jpegData(compressionQuality: quality)!
        self.name = name
        self.contentType = "image/jpg"
        super.init()
    }
}
