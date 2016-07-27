//
//  HIViewController.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

public var HIViewControllerStatusBarStyle: UIStatusBarStyle = .Default

public class HIViewController: UIViewController {
    
    private var oldKbHeight = CGFloat(0)
    private var closeGesture: UITapGestureRecognizer? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        closeGesture = UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard))
        closeGesture!.enabled = false
        self.view.addGestureRecognizer(closeGesture!)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let names = [UIKeyboardWillShowNotification, UIKeyboardWillHideNotification, UIKeyboardWillChangeFrameNotification]
        for (_, name) in names.enumerate() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: nil)
        }
    }
    
    @IBAction public func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    public func shouldUseCloseGesture() -> Bool {
        return true
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return HIViewControllerStatusBarStyle
    }
    
    public func keyboardWillAppear(notification: NSNotification) {
        if (shouldUseCloseGesture()) {
            closeGesture?.enabled = true
        }
    }
    
    public func keyboardWillDisappear(notification: NSNotification) {
        closeGesture?.enabled = false
    }
    
    public func keyboardWillChangeFrame(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        var kbEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        kbEndFrame = self.view.convertRect(kbEndFrame, fromView: nil)
        
        var kbStartFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        kbStartFrame = self.view.convertRect(kbStartFrame, fromView: nil)
        
        var kbHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(kbEndFrame)
        if kbHeight < 0 {
            kbHeight = 0
        }
        
        let kbOffset = kbHeight - oldKbHeight
        oldKbHeight = kbHeight
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue)
        let curve = UIViewAnimationCurve.init(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        self.viewWillAdjustForKeyboardFrameChange(kbOffset)
        
        UIView.commitAnimations()
    }
    
    public func viewWillAdjustForKeyboardFrameChange(keyboardOffset: CGFloat) {
        
    }
}