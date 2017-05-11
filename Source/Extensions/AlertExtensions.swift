//
//  AlertExtensions.swift
//  Pods
//
//  Created by Vlad Getman on 28.07.16.
//
//

import Foundation

public protocol AlertErrorDelegate: NSObjectProtocol {
    func shouldShowError(_ error: NSError) -> Bool
    func textForError(_ error: NSError) -> String
}

public extension UIAlertController {
    
    public class func show(title: String, messageObject: NSObject?) {
        var msg: String?
        if let message = messageObject as? String {
            msg = message
        } else if messageObject != nil {
            msg = messageObject!.description
        }
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.show()
    }
    
    public class func show(title: String, message: String) {
       show(title: title, messageObject: message as NSObject?)
    }
    
    public class func showError(_ message: String) {
        UIAlertController.show(title: "Error", message: message)
    }
    
    public func show() {
        show(true)
    }
    
    public func show(_ animated: Bool) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow!.rootViewController = AlertShowController()
        alertWindow!.windowLevel = UIWindowLevelAlert + 1
        alertWindow!.makeKeyAndVisible()
        alertWindow!.rootViewController?.present(self, animated: true, completion: nil)
    }
}

extension UIAlertController {
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.isHidden = true
        alertWindow = nil
    }
}

public extension NSError {
    
    public static var errorDelegate: AlertErrorDelegate?
    
    public func showAlert() {
        
        if let delegate = NSError.errorDelegate {
            if delegate.shouldShowError(self) {
                UIAlertController.showError(delegate.textForError(self))
            }
        } else {
            UIAlertController.showError(self.localizedDescription)
        }
    }
}

var AssociatedWindow: UInt8 = 0
var OriginalWindow: UInt8 = 1

private extension UIAlertController {
    var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &AssociatedWindow) as? UIWindow
        }
        set {
            if newValue != nil {
                originalWindow = UIApplication.shared.keyWindow
            } else {
                originalWindow?.makeKeyAndVisible()
            }
            objc_setAssociatedObject(self, &AssociatedWindow, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var originalWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &OriginalWindow) as? UIWindow
        }
        set {
            objc_setAssociatedObject(self, &OriginalWindow, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private class AlertShowController: UIViewController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return HIViewControllerStatusBarStyle
    }
}
