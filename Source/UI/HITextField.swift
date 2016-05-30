//
//  HITextField.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

@IBDesignable
public class HITextField: UITextField {
    
    @IBInspectable public var image: UIImage? {
        didSet {
            invalidateImageView()
        }
    }
    
    @IBInspectable public var leftViewWidth: CGFloat = 0 {
        didSet {
            invalidateImageView()
        }
    }
    
    @IBInspectable public var placeholderTextColor: UIColor? {
        didSet {
            self.setPlaceholderColor(placeholderTextColor!)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func invalidateImageView() {
        if (leftViewWidth <= 0 || image == nil) {
            self.leftView = nil
            self.rightView = nil
        } else {
            let imageView = UIImageView.init(image: image)
            imageView.frame = CGRectMake(0, 0, leftViewWidth, CGRectGetHeight(self.frame))
            imageView.contentMode = .Center
            self.leftView = imageView
            self.leftViewMode = .Always
            
            let rightView = UIView.init(frame: CGRectMake(0, 0, 5, 5))
            self.rightView = rightView
            self.rightViewMode = .Always
        }
    }
    
}