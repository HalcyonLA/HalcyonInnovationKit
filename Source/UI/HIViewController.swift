//
//  HIViewController.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

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
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction public func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    public func shouldUseCloseGesture() -> Bool {
        return true
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
        var kbEndFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        kbEndFrame = self.view.convertRect(kbEndFrame, fromView: nil)
        
        var kbStartFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        kbStartFrame = self.view.convertRect(kbStartFrame, fromView: nil)
        
        let kbHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(kbEndFrame);
        let kbOffset = kbHeight - oldKbHeight // = CGRectGetMinY(kbStartFrame) - CGRectGetMinY(kbEndFrame)
        oldKbHeight = kbHeight
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue)
        UIView.setAnimationCurve(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        self.viewWillAdjustForKeyboardFrameChange(kbOffset)
        
        UIView.commitAnimations()
    }
    
    public func viewWillAdjustForKeyboardFrameChange(keyboardOffset: CGFloat) {
        
    }
}