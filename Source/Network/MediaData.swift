//
//  MediaData.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

open class MediaData: NSObject {
    
    open var data: Data?
    open var name: String?
    open var contentType: String?
    
    public init(data: Data, name: String, contentType: String) {
        super.init()
        self.data = data
        self.name = name
        self.contentType = contentType
    }
    
    public init(jpegImage: UIImage, quality: Float = 0.9, name: String = "photo.jpg") {
        super.init()
        self.data = UIImageJPEGRepresentation(jpegImage, CGFloat(quality))
        self.name = name
        self.contentType = "image/jpg"
    }
}
