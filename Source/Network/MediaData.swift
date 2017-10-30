//
//  MediaData.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

@objc open class MediaData: NSObject {
    
    @objc open var data: Data?
    @objc open var name: String?
    @objc open var contentType: String?
    
    @objc public init(data: Data, name: String, contentType: String) {
        super.init()
        self.data = data
        self.name = name
        self.contentType = contentType
    }
    
    @objc public init(jpegImage: UIImage, quality: Float = 0.9, name: String = "photo.jpg") {
        super.init()
        self.data = UIImageJPEGRepresentation(jpegImage, CGFloat(quality))
        self.name = name
        self.contentType = "image/jpg"
    }
}
