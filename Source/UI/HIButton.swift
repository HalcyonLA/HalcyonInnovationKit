//
//  HIButton.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

@IBDesignable
open class HIButton: UIButton {
    @IBInspectable open var backgroundImageColor: UIColor? {
        didSet {
            self.setBackgroundImageWithColor(backgroundImageColor!)
        }
    }
}
