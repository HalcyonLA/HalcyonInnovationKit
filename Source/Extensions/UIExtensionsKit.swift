//
//  ViewKit.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation
import MBProgressHUD
import MapKit
import SDWebImage

@IBDesignable public extension UIView {
    var width:      CGFloat { return self.frame.size.width }
    var height:     CGFloat { return self.frame.size.height }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
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
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
    }
    
    public func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @discardableResult
    public func showLoadingHUD(_ show: Bool) -> MBProgressHUD? {
        if (show) {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Loading"
            hud.removeFromSuperViewOnHide = true
            return hud
        } else {
            MBProgressHUD.hide(for: self, animated: true)
            return nil
        }
    }
    
    public func shake() {
        let kAnimationShake = "Shake"
        let shakeAnimation = self.shakeAnimation()
        
        layer.removeAnimation(forKey: kAnimationShake)
        layer.add(shakeAnimation, forKey: kAnimationShake)
    }

    fileprivate func shakeAnimation() -> CAAnimation {
        let frameValues = [transformTranslateX(10.0), transformTranslateX(-10.0), transformTranslateX(6.0), transformTranslateX(-6.0),transformTranslateX(3.0), transformTranslateX(-3.0), transformTranslateX(0.0)]
        let frameTimes = [NSNumber(value: 0.14 as Float), NSNumber(value: 0.28 as Float), NSNumber(value: 0.42 as Float) ,NSNumber(value: 0.57 as Float), NSNumber(value: 0.71 as Float), NSNumber(value: 0.85 as Float), NSNumber(value: 1 as Float)]
        return animationWithValues(frameValues, times: frameTimes, duration: 0.5)
    }
    
    fileprivate func transformTranslateX(_ translate: Float) -> NSValue {
        return NSValue(caTransform3D: transform3DTranslateX(translate))
    }
    
    fileprivate func transformTranslateY(_ translate: Float) -> NSValue {
        return NSValue(caTransform3D: transform3DTranslateY(translate))
    }
    
    fileprivate func transformScale(_ scale: Float) -> NSValue {
        return NSValue(caTransform3D: transform3DScale(scale))
    }
    
    fileprivate func transform3DScale(_ scale: Float) -> CATransform3D {
        // Add scale on current transform.
        return CATransform3DScale(layer.transform, CGFloat(scale), CGFloat(scale), 1)
    }
    
    fileprivate func transform3DTranslateX(_ translate: Float) -> CATransform3D {
        // Add scale on current transform.
        return CATransform3DTranslate(layer.transform, CGFloat(translate), 1, 1)
    }
    
    fileprivate func transform3DTranslateY(_ translate: Float) -> CATransform3D {
        // Add scale on current transform.
        return CATransform3DTranslate(layer.transform, 1, CGFloat(translate), 1)
    }
    
    fileprivate func animationWithValues(_ values: [NSValue], times: [NSNumber], duration: Float) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.values = values
        animation.keyTimes = times
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.isRemovedOnCompletion = false
        animation.duration = Double(duration)
        return animation
    }
}

public extension UIImageView {
    public func setImageWithString(_ urlString: String?, placeholderImage: UIImage? = nil, activityIndicatorStyle: UIActivityIndicatorViewStyle) {
        if urlString == nil || urlString?.length == 0 {
            image = placeholderImage
        } else {
            sd_setShowActivityIndicatorView(true)
            sd_setIndicatorStyle(activityIndicatorStyle)
            if let url = URL(string: urlString!) {
                sd_setImage(with: url, placeholderImage: placeholderImage)
            }
        }
    }
}

public extension UITextField {
    public func setPlaceholderColor(_ color: UIColor) {
        if let text = placeholder {
            attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:color])
        }
    }
    
    public func setLeft(padding: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        leftViewMode = .always
    }
    
    public func setRight(padding: CGFloat) {
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        rightViewMode = .always
    }
    
    public func setPaddings(_ padding: CGFloat) {
        setLeft(padding: padding)
        setRight(padding: padding)
    }
}

public extension UITextView {
    public func clearInsets() {
        textContainer.lineFragmentPadding = 0
        textContainerInset = .zero
    }
}

public extension UIButton {
    public func backgroundToImage() {
        if let color = backgroundColor {
            setBackgroundImageWithColor(color)
            backgroundColor = nil
            layer.masksToBounds = true
        }
    }
    
    public func setBackgroundImageWithColor(_ backgroundColor: UIColor) {
        let background = UIImage.imageWithColor(backgroundColor)
        self.setBackgroundImage(background, for: UIControlState())
    }
}

public extension UIViewController {
    public class func top() -> UIViewController {
        var top = UIApplication.shared.keyWindow!.rootViewController!
        while top.presentedViewController != nil {
            top = top.presentedViewController!
        }
        return top
    }
    
    public func prepareForTransparency() {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
    }
}

public extension UIBarButtonItem {
    public class func spacerWithWidth(_ width: Float) -> UIBarButtonItem {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = CGFloat(width)
        return spacer
    }
}

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable { }
extension UITableViewHeaderFooterView: Reusable { }
extension UICollectionReusableView: Reusable { }
extension MKAnnotationView: Reusable { }

public extension UIScrollView {
    public func scrollToEnd(_ animated: Bool = true) {
        var offset = CGPoint.zero
        let inset = contentInset
        if (contentSize.height > contentSize.width) {
            offset = CGPoint(x: 0, y: contentSize.height - self.height + inset.bottom)
        } else {
            offset = CGPoint(x: contentSize.width - self.width + inset.right, y: 0)
        }
        self.setContentOffset(offset, animated: animated)
    }
    
    public var topRefreshControl: UIRefreshControl? {
        set {
            if #available(iOS 10.0, *) {
                self.refreshControl = newValue
            } else {
                if let control = newValue {
                    control.tag = 1234
                    control.layer.masksToBounds = true
                    self.insertSubview(control, at: 0)
                } else {
                    topRefreshControl?.removeFromSuperview()
                }
            }
        }
        get {
            if #available(iOS 10.0, *) {
                return self.refreshControl
            } else {
                return self.subviews.filter({ (view) -> Bool in
                    if let control = view as? UIRefreshControl {
                        if control.tag == 1234 {
                            return true
                        }
                    }
                    return false
                }).first as? UIRefreshControl
            }
        }
    }
}

public extension UITableView {
    
    public override func scrollToEnd(_ animated: Bool = true) {
        if let dataSource = self.dataSource {
            var section = dataSource.numberOfSections?(in: self)
            if section == nil {
                section = 0
            } else {
                section! -= 1
            }
            if section! >= 0 {
                let row = dataSource.tableView(self, numberOfRowsInSection: section!) - 1
                if row >= 0 {
                    let indexPath = IndexPath(row: row, section: section!)
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    
    public func registerReusable(_ cellClass: Reusable.Type, withNib: Bool = true) {
        let reuseIdentifier = cellClass.reuseIdentifier
        self.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: reuseIdentifier, bundle: nil)
            self.register(nib, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    public func dequeueReusableCellWithClass<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T where T: Reusable {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    public func registerReusableHeaderFooterViewClass(_ headerFooterViewClass: Reusable.Type, withNib: Bool = false) {
        let reuseIdentifier = headerFooterViewClass.reuseIdentifier
        self.register(headerFooterViewClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: reuseIdentifier, bundle: nil)
            self.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
    }
    
    public func dequeueReusableHeaderFooterViewWithClass<T: UITableViewHeaderFooterView>(_ headerFooterViewClass: T.Type = T.self) -> T? where T: Reusable {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
    }
}

public extension UICollectionView {
    public func registerReusable(_ cellClass: Reusable.Type, withNib: Bool = true) {
        let reuseIdentifier = cellClass.reuseIdentifier
        self.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: reuseIdentifier, bundle: nil)
            self.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        }
    }
    
    public func registerReusable(_ viewClass: Reusable.Type, elementKind: String, withNib: Bool = true) {
        let reuseIdentifier = viewClass.reuseIdentifier
        self.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        if withNib {
            let nib = UINib(nibName: reuseIdentifier, bundle: nil)
            self.register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
    }
    
    public func dequeueReusableCellWithClass<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T where T: Reusable {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    public func dequeueReusableSupplementaryViewWithClass<T: UICollectionReusableView>(_ viewClass: T.Type, elementKind: String, indexPath: IndexPath) -> T where T: Reusable {
        return self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

public extension MKMapView {
    public func dequeueReusableAnnotationViewWithClass<T: MKAnnotationView>(_ annotationViewClass: T.Type, annotation: MKAnnotation) -> T where T: Reusable {
        
        let identifier = annotationViewClass.reuseIdentifier
        
        var annotationView = self.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = T(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView as! T
    }
}

// MARK: Storyboard helpers

public extension UIStoryboard {
    class func main() -> UIStoryboard! {
        guard let mainStoryboardName = Bundle.main.infoDictionary?["UIMainStoryboardFile"] as? String else {
            assertionFailure("No UIMainStoryboardFile found in main bundle")
            return nil
        }
        return UIStoryboard(name: mainStoryboardName, bundle: nil)
    }
}

protocol StoryboardInstantiable {
    static var storyboardIdentifier: String {get}
    static func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self
}

extension UIViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        // Get the name of current class
        let classString = NSStringFromClass(self)
        let components = classString.components(separatedBy: ".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
    public class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboard(storyboard, type: self)
    }
    
    public class func storyboardInstance(_ storyboard: String) -> Self {
        return storyboardInstance(storyboard, type: self)
    }
    
    public class func mainStoryboardInstance() -> Self {
        return instantiateFromStoryboard(UIStoryboard.main(), type: self)
    }
    
    fileprivate class func instantiateFromStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, type: T.Type) -> T {
        return storyboard.instantiateViewController(withIdentifier: self.storyboardIdentifier) as! T
    }
    
    fileprivate class func storyboardInstance<T: UIViewController>(_ storyboard: String, type: T.Type) -> T {
        let sb = UIStoryboard(name: storyboard, bundle: nil)
        return sb.instantiateViewController(withIdentifier: self.storyboardIdentifier) as! T
    }
}
