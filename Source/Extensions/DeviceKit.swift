//
//  DeviceKit.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

public enum DeviceMaxHeight: Float {
    case iPhone4     = 480.0
    case iPhone5     = 568.0
    case iPhone6     = 667.0
    case iPhone6Plus = 736.0
    case iPad        = 1024.0
    case iPadPro     = 1366.0
}

@objc public enum DeviceType: Int {
    case iPhone
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPad
    case iPadPro
    case Unknown
}

public extension UIDevice {
    
    public class func systemVersion() -> Float  {
        return NSString(string: UIDevice.currentDevice().systemVersion).floatValue
    }
    
    public class func deviceHeight() -> Float {
        let w = Float(UIScreen.mainScreen().bounds.width)
        let h = Float(UIScreen.mainScreen().bounds.height)
        return fmax(w, h)
    }
    
    public class func deviceWidth() -> Float {
        let w = Float(UIScreen.mainScreen().bounds.width)
        let h = Float(UIScreen.mainScreen().bounds.height)
        return fmin(w, h)
    }
    
    public class func deviceType() -> DeviceType {
        if isPhone4()     { return DeviceType.iPhone4     }
        if isPhone5()     { return DeviceType.iPhone5     }
        if isPhone6()     { return DeviceType.iPhone6     }
        if isPhone6Plus() { return DeviceType.iPhone6Plus }
        if isPadPro()     { return DeviceType.iPadPro     }
        if isPad()        { return DeviceType.iPad        }
        if isPhone()      { return DeviceType.iPhone      }
        return DeviceType.Unknown
    }
    
    public class func isPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }
    
    public class func isPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    public class func isPhone4() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone4.rawValue
    }
    
    public class func isPhone5() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone5.rawValue
    }
    
    public class func isPhone6() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone6.rawValue
    }
    
    public class func isPhone6Plus() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhone6Plus.rawValue
    }
    
    public class func isPadPro() -> Bool {
        return isPad() && deviceHeight() == DeviceMaxHeight.iPadPro.rawValue
    }
    
}