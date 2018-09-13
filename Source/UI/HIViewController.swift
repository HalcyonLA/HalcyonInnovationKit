//
//  HIViewController.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

public var HIViewControllerStatusBarStyle: UIStatusBarStyle = .default

@objc open class HIViewController: UIViewController {
    
    private var oldKbHeight: CGFloat = 0
    
    open lazy var closeGesture: UITapGestureRecognizer = {
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        closeGesture.isEnabled = false
        return closeGesture
    }()
    
    open private(set) var keyboardAppeared: Bool = false
    
    open var keyboardHeight: CGFloat {
        return oldKbHeight
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(closeGesture)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillDisappear(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let names: [NSNotification.Name] = [UIResponder.keyboardWillShowNotification,
                                            UIResponder.keyboardWillHideNotification,
                                            UIResponder.keyboardWillChangeFrameNotification]
        for name in names {
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
    }
    
    @IBAction open func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc open func shouldUseCloseGesture() -> Bool {
        return true
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return HIViewControllerStatusBarStyle
    }
    
    @objc open func keyboardWillAppear(_ notification: Notification) {
        keyboardAppeared = true
        if shouldUseCloseGesture() {
            closeGesture.isEnabled = true
        }
    }
    
    @objc open func keyboardWillDisappear(_ notification: Notification) {
        closeGesture.isEnabled = false
        keyboardAppeared = false
    }
    
    @objc open func keyboardWillChangeFrame(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        var kbEndFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        kbEndFrame = view.convert(kbEndFrame, from: nil)
        
        var kbStartFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        kbStartFrame = view.convert(kbStartFrame, from: nil)
        
        var kbHeight = view.frame.height - kbEndFrame.minY
        if kbHeight < 0 {
            kbHeight = 0
        }
        
        let kbOffset = kbHeight - oldKbHeight
        oldKbHeight = kbHeight
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue)
        let curve = UIView.AnimationCurve(rawValue: (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).intValue)!
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        keyboardFrameWillChange(with: kbStartFrame, endFrame: kbEndFrame)
        viewWillAdjustForKeyboardFrameChange(kbOffset)
        
        UIView.commitAnimations()
    }
    
    @objc open func keyboardFrameWillChange(with startFrame: CGRect, endFrame: CGRect) {
        
    }
    
    @objc open func viewWillAdjustForKeyboardFrameChange(_ keyboardOffset: CGFloat) {
        
    }
}
