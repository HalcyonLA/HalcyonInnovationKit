//
//  AlertExtensions.swift
//  Pods
//
//  Created by Vlad Getman on 28.07.16.
//
//

import Foundation

public extension UIAlertController {
    public class func show(title title: String, message: NSObject?) {
        var msg: String?
        if (message != nil) {
            if (message is String) {
                msg = message! as? String
            } else {
                msg = message!.description
            }
        }
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .Cancel, handler: nil))
        alert.show()
    }
    
    public class func showError(message: String) {
        UIAlertController.show(title: "Error", message: message)
    }
    
    public func show() {
        show(true)
    }
    
    public func show(animated: Bool) {
        alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        alertWindow!.rootViewController = AlertShowController()
        alertWindow!.windowLevel = UIWindowLevelAlert + 1
        alertWindow!.makeKeyAndVisible()
        alertWindow!.rootViewController?.presentViewController(self, animated: true, completion: nil)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.hidden = true
        alertWindow = nil
    }
}

public extension NSError {
    public func showAlert() {
        UIAlertController.showError(self.localizedDescription)
    }
}

var AssociatedWindow: UInt8 = 0

private extension UIAlertController {
    var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &AssociatedWindow) as? UIWindow
        }
        set {
            objc_setAssociatedObject(self, &AssociatedWindow, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private class AlertShowController: UIViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return HIViewControllerStatusBarStyle
    }
}