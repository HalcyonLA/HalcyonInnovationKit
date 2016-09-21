//
//  HITextField.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

@IBDesignable
open class HITextField: UITextField {
    
    @IBInspectable open var image: UIImage? {
        didSet {
            invalidateImageView()
        }
    }
    
    @IBInspectable open var leftViewWidth: CGFloat = 0 {
        didSet {
            invalidateImageView()
        }
    }
    
    @IBInspectable open var placeholderTextColor: UIColor? {
        didSet {
            self.setPlaceholderColor(placeholderTextColor!)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func invalidateImageView() {
        if (leftViewWidth <= 0 || image == nil) {
            self.leftView = nil
            self.rightView = nil
        } else {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: leftViewWidth, height: self.frame.height)
            imageView.contentMode = .center
            self.leftView = imageView
            self.leftViewMode = .always
            
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
    
}
