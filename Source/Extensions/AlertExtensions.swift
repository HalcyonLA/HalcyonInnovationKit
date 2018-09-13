//
//  AlertExtensions.swift
//  Pods
//
//  Created by Vlad Getman on 28.07.16.
//
//

import Foundation

@objc public protocol AlertErrorDelegate: NSObjectProtocol {
    @objc func shouldShowError(_ error: NSError) -> Bool
    @objc func textForError(_ error: NSError) -> String
}

public extension UIAlertController {
    
    @objc public class func show(title: String, messageObject: NSObject?) {
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
    
    @objc public class func show(title: String, message: String) {
       show(title: title, messageObject: message as NSObject?)
    }
    
    @objc public class func showError(_ message: String) {
        UIAlertController.show(title: "Error", message: message)
    }
    
    @objc public func show() {
        show(true)
    }
    
    @objc public func show(_ animated: Bool) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow!.rootViewController = AlertShowController()
        alertWindow!.windowLevel = .alert + 1
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

public extension Error {
    public func showAlert() {
        (self as NSError).showAlert()
    }
}

public extension NSError {
    
    @objc public static var errorDelegate: AlertErrorDelegate?
    
    @objc public func showAlert() {
        if let delegate = NSError.errorDelegate {
            if delegate.shouldShowError(self) {
                UIAlertController.showError(delegate.textForError(self))
            }
        } else {
            UIAlertController.showError(self.localizedDescription)
        }
    }
    
    @objc public func showAlert(retryHandle: @escaping () -> ()) {
        let text: String?
        if let delegate = NSError.errorDelegate {
            if delegate.shouldShowError(self) {
                text = delegate.textForError(self)
            } else {
                text = nil
            }
        } else {
            text = localizedDescription
        }
        guard let errorText = text else {
            return
        }
        
        let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
            retryHandle()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.show()
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
