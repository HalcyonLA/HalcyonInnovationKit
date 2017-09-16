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
    case iPad
    case iPadPro
    case unknown
}

public extension UIDevice {
    
    public class func systemVersion() -> Float  {
        return NSString(string: UIDevice.current.systemVersion).floatValue
    }
    
    public class func deviceHeight() -> CGFloat {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        return max(w, h)
    }
    
    public class func deviceWidth() -> CGFloat {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        return min(w, h)
    }
    
    public class func deviceType() -> DeviceType {
        if isPhone4()     { return DeviceType.iPhone4     }
        if isPhone5()     { return DeviceType.iPhone5     }
        if isPhone6()     { return DeviceType.iPhone6     }
        if isPhone6Plus() { return DeviceType.iPhone6Plus }
        if isPadPro()     { return DeviceType.iPadPro     }
        if isPad()        { return DeviceType.iPad        }
        if isPhone()      { return DeviceType.iPhone      }
        return DeviceType.unknown
    }
    
    public class func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    public class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
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
    
    public class func isPhoneX() -> Bool {
        return isPhone() && deviceHeight() == DeviceMaxHeight.iPhoneX.rawValue
    }
    
    public class func isPadPro() -> Bool {
        return isPad() && deviceHeight() == DeviceMaxHeight.iPadPro.rawValue
    }
    
}
