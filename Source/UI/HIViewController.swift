//
//  HIViewController.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

public var HIViewControllerStatusBarStyle: UIStatusBarStyle = .default

open class HIViewController: UIViewController {
    
    fileprivate var oldKbHeight = CGFloat(0)
    fileprivate var closeGesture: UITapGestureRecognizer? = nil
    open fileprivate(set) var keyboardAppeared: Bool = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        closeGesture!.isEnabled = false
        self.view.addGestureRecognizer(closeGesture!)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let names = [NSNotification.Name.UIKeyboardWillShow, NSNotification.Name.UIKeyboardWillHide, NSNotification.Name.UIKeyboardWillChangeFrame]
        for (_, name) in names.enumerated() {
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
    }
    
    @IBAction open func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    open func shouldUseCloseGesture() -> Bool {
        return true
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return HIViewControllerStatusBarStyle
    }
    
    open func keyboardWillAppear(_ notification: Notification) {
        keyboardAppeared = true
        if (shouldUseCloseGesture()) {
            closeGesture?.isEnabled = true
        }
    }
    
    open func keyboardWillDisappear(_ notification: Notification) {
        closeGesture?.isEnabled = false
        keyboardAppeared = false
    }
    
    open func keyboardWillChangeFrame(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo!
        
        var kbEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        kbEndFrame = self.view.convert(kbEndFrame!, from: nil)
        
        var kbStartFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        kbStartFrame = self.view.convert(kbStartFrame!, from: nil)
        
        var kbHeight = self.view.frame.height - (kbEndFrame?.minY)!
        if kbHeight < 0 {
            kbHeight = 0
        }
        
        let kbOffset = kbHeight - oldKbHeight
        oldKbHeight = kbHeight
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue)
        let curve = UIViewAnimationCurve.init(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).intValue)!
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        self.viewWillAdjustForKeyboardFrameChange(kbOffset)
        
        UIView.commitAnimations()
    }
    
    open func viewWillAdjustForKeyboardFrameChange(_ keyboardOffset: CGFloat) {
        
    }
}
