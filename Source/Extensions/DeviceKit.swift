//
//  DeviceKit.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

public enum DeviceMaxHeight: CGFloat {
    case iPhone4     = 480.0
    case iPhone5     = 568.0
    case iPhone6     = 667.0
    case iPhone6Plus = 736.0
    case iPhoneX     = 812.0
    case iPhoneXMax  = 896.0
    case iPad        = 1024.0
    case iPadPro     = 1366.0
}

@objc public enum DeviceType: Int {
    case iPhone
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPhoneX
    case iPhoneXMax
    case iPad
    case iPadPro
    case unknown
}

public extension UIDevice {
    
    @objc class func systemVersion() -> Float  {
        return NSString(string: UIDevice.current.systemVersion).floatValue
    }
    
    @objc class func deviceHeight() -> CGFloat {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        return max(w, h)
    }
    
    @objc class func deviceWidth() -> CGFloat {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        return min(w, h)
    }
    
    @objc class func deviceType() -> DeviceType {
        if isPhone4()     { return DeviceType.iPhone4     }
        if isPhone5()     { return DeviceType.iPhone5     }
        if isPhone6()     { return DeviceType.iPhone6     }
        if isPhone6Plus() { return DeviceType.iPhone6Plus }
        if isPhoneX()     { return DeviceType.iPhoneX     }
        if isPhoneXMax()  { return DeviceType.iPhoneXMax  }
        if isPadPro()     { return DeviceType.iPadPro     }
        if isPad()        { return DeviceType.iPad        }
        if isPhone()      { return DeviceType.iPhone      }
        return DeviceType.unknown
    }
    
    @objc class func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    @objc class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @objc class func isPhone4() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone4.rawValue
    }
    
    @objc class func isPhone5() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone5.rawValue
    }
    
    @objc class func isPhone6() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone6.rawValue
    }
    
    @objc class func isPhone6Plus() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone6Plus.rawValue
    }
    
    @objc class func isPhoneX() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhoneX.rawValue
    }
    
    @objc class func isPhoneXMax() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhoneXMax.rawValue
    }
    
    @objc class func isPadPro() -> Bool {
        return isPad() && deviceHeight() == DeviceMaxHeight.iPadPro.rawValue
    }
    
}
