//
//  ViewKit.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation
import MBProgressHUD

@IBDesignable public extension UIView {
    var width:      CGFloat { return self.frame.size.width }
    var height:     CGFloat { return self.frame.size.height }
    
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.CGColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(CGColor:color)
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    public func applyFullAutoresizingMask() {
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
    }
    
    public func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func showLoadingHUD(show: Bool) -> MBProgressHUD? {
        if (show) {
            let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
            hud.mode = .Indeterminate
            hud.label.text = "Loading"
            hud.removeFromSuperViewOnHide = true
            return hud
        } else {
            MBProgressHUD.hideHUDForView(self, animated: true)
            return nil
        }
    }
    
    public func shake() {
        let kAnimationShake = "Shake"
        let shakeAnimation = self.shakeAnimation()
        
        self.layer.removeAnimationForKey(kAnimationShake)
        self.layer.addAnimation(shakeAnimation, forKey: kAnimationShake)
    }

    private func shakeAnimation() -> CAAnimation {
        let frameValues = [transformTranslateX(10.0), transformTranslateX(-10.0), transformTranslateX(6.0), transformTranslateX(-6.0),transformTranslateX(3.0), transformTranslateX(-3.0), transformTranslateX(0.0)]
        let frameTimes = [NSNumber.init(float: 0.14), NSNumber.init(float: 0.28), NSNumber.init(float: 0.42) ,NSNumber.init(float: 0.57), NSNumber.init(float: 0.71), NSNumber.init(float: 0.85), NSNumber.init(float: 1)]
        return self.animationWithValues(frameValues, times: frameTimes, duration: 0.5)
    }
    
    private func transformTranslateX(translate: Float) -> NSValue {
        return NSValue.init(CATransform3D: self.transform3DTranslateX(translate))
    }
    
    private func transformTranslateY(translate: Float) -> NSValue {
        return NSValue.init(CATransform3D: self.transform3DTranslateY(translate))
    }
    
    private func transformScale(scale: Float) -> NSValue {
        return NSValue.init(CATransform3D: self.transform3DScale(scale))
    }
    
    private func transform3DScale(scale: Float) -> CATransform3D {
        // Add scale on current transform.
        return CATransform3DScale(self.layer.transform, CGFloat(scale), CGFloat(scale), 1)
    }
    
    private func transform3DTranslateX(translate: Float) -> CATransform3D {
        // Add scale on current transform.
        return CATransform3DTranslate(self.layer.transform, CGFloat(translate), 1, 1)
    }
    
    private func transform3DTranslateY(translate: Float) -> CATransform3D {
        // Add scale on current transform.
        return CATransform3DTranslate(self.layer.transform, 1, CGFloat(translate), 1)
    }
    
    private func animationWithValues(values: [NSValue], times: [NSNumber], duration: Float) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation.init(keyPath: "transform")
        animation.values = values
        animation.keyTimes = times
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        animation.removedOnCompletion = false
        animation.duration = Double(duration)
        return animation
    }
}

public extension UIImageView {
    public func setImageWithString(urlString: String?, placeholderImage: UIImage? = nil, activityIndicatorStyle: UIActivityIndicatorViewStyle) {
        if urlString == nil || urlString?.length == 0 {
            self.image = placeholderImage
        } else {
            let url = NSURL.init(string: urlString!)!
            self.setImageWithURL(url, placeholderImage: placeholderImage, usingActivityIndicatorStyle: activityIndicatorStyle)
        }
    }
}

public extension UITextField {
    public func setPlaceholderColor(color: UIColor) {
        if (self.placeholder?.length > 0) {
            self.attributedPlaceholder = NSAttributedString.init(string: self.placeholder!, attributes: [NSForegroundColorAttributeName:color])
        }
    }
    
    public func setLeftPaddinng(padding: Float) {
        self.leftView = UIView.init(frame: CGRectMake(0, 0, CGFloat(padding), 1))
        self.leftViewMode = .Always
    }
}

public extension UITextView {
    public func clearInsets() {
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsetsZero
    }
}

public extension UIButton {
    public func backgroundToImage() {
        if (self.backgroundColor != nil) {
            self.setBackgroundImageWithColor(self.backgroundColor!)
            self.backgroundColor = nil
            self.layer.masksToBounds = true
        }
    }
    
    public func setBackgroundImageWithColor(backgroundColor: UIColor) {
        let background = UIImage.imageWithColor(backgroundColor)
        self.setBackgroundImage(background, forState: .Normal)
    }
}

public extension UIViewController {
    public class func top() -> UIViewController {
        var top = UIApplication.sharedApplication().keyWindow!.rootViewController!
        while top.presentedViewController != nil {
            top = top.presentedViewController!
        }
        return top
    }
    
    public func prepareForTransparency() {
        self.providesPresentationContextTransitionStyle = true;
        self.definesPresentationContext = true;
        self.modalPresentationStyle = .OverCurrentContext;
    }
}

public extension UIBarButtonItem {
    public class func spacerWithWidth(width: Float) -> UIBarButtonItem {
        let spacer = UIBarButtonItem.init(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        spacer.width = CGFloat(width)
        return spacer
    }
}

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(self)
    }
}

extension UITableViewCell: Reusable { }
extension UITableViewHeaderFooterView: Reusable { }
extension UICollectionReusableView: Reusable { }

public extension UIScrollView {
    public func scrollToEnd(animated: Bool = true) {
        var offset = CGPointZero
        if (contentSize.height > contentSize.width) {
            offset = CGPointMake(0, contentSize.height - self.height)
        } else {
            offset = CGPointMake(contentSize.width - self.width, 0)
        }
        self.setContentOffset(offset, animated: animated)
    }
}

public extension UITableView {
    public func registerReusable(cellClass: Reusable.Type, withNib: Bool = true) -> UITableView {
        self.registerClass(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: cellClass.reuseIdentifier, bundle: nil)
            self.registerNib(nib, forCellReuseIdentifier: cellClass.reuseIdentifier)
        }
        return self
    }
    
    public func dequeueReusableCellWithClass<T: UITableViewCell where T: Reusable>(cellClass: T.Type, indexPath: NSIndexPath) -> T {
        return self.dequeueReusableCellWithIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as! T
    }
    
    public func registerReusableHeaderFooterViewClass(headerFooterViewClass: Reusable.Type, withNib: Bool = false) -> UITableView {
        self.registerClass(headerFooterViewClass, forHeaderFooterViewReuseIdentifier: headerFooterViewClass.reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: headerFooterViewClass.reuseIdentifier, bundle: nil)
            self.registerNib(nib, forHeaderFooterViewReuseIdentifier: headerFooterViewClass.reuseIdentifier)
        }
        return self
    }
    
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView where T: Reusable>(headerFooterViewClass: T.Type = T.self) -> T? {
        return self.dequeueReusableHeaderFooterViewWithIdentifier(T.reuseIdentifier) as? T
    }
}

public extension UICollectionView {
    public func registerReusable(cellClass: Reusable.Type, withNib: Bool = true) -> UICollectionView {
        self.registerClass(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: cellClass.reuseIdentifier, bundle: nil)
            self.registerNib(nib, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        }
        return self
    }
    
    public func dequeueReusableCellWithClass<T: UICollectionViewCell where T: Reusable>(cellClass: T.Type, indexPath: NSIndexPath) -> T {
        return self.dequeueReusableCellWithReuseIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as! T
    }
    
    public func dequeueReusableSupplementaryViewWithClass<T: UICollectionReusableView where T: Reusable>(elementKind: String, cellClass: T.Type, indexPath: NSIndexPath) -> T {
        return self.dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: T.reuseIdentifier, forIndexPath: indexPath) as! T
    }
}

// MARK: Storyboard helpers

public extension UIStoryboard {
    class func main() -> UIStoryboard! {
        guard let mainStoryboardName = NSBundle.mainBundle().infoDictionary?["UIMainStoryboardFile"] as? String else {
            assertionFailure("No UIMainStoryboardFile found in main bundle")
            return nil
        }
        return UIStoryboard(name: mainStoryboardName, bundle: nil)
    }
}

protocol StoryboardInstantiable {
    static var storyboardIdentifier: String {get}
    static func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self
}

extension UIViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        // Get the name of current class
        let classString = NSStringFromClass(self)
        let components = classString.componentsSeparatedByString(".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
    public class func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboard(storyboard, type: self)
    }
    
    public class func storyboardInstance(storyboard: String) -> Self {
        return storyboardInstance(storyboard, type: self)
    }
    
    public class func mainStoryboardInstance() -> Self {
        return instantiateFromStoryboard(UIStoryboard.main(), type: self)
    }
    
    
    private class func instantiateFromStoryboard<T: UIViewController>(storyboard: UIStoryboard, type: T.Type) -> T {
        return storyboard.instantiateViewControllerWithIdentifier(self.storyboardIdentifier) as! T
    }
    
    private class func storyboardInstance<T: UIViewController>(storyboard: String, type: T.Type) -> T {
        let sb = UIStoryboard(name: storyboard, bundle: nil)
        return sb.instantiateViewControllerWithIdentifier(self.storyboardIdentifier) as! T
    }
}
