//
//  ExtensionsKit.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation
import QuartzCore
import Accelerate
import MapKit

public func UIColorFromHex(_ hex: UInt32) -> UIColor {
    return UIColor.init(hex: hex)
}

public func UIColorFromHexWithAlpha(_ hex: UInt32, alpha: Float) -> UIColor {
    return UIColor.init(hex: hex, alpha: alpha)
}

public func AppName() -> String {
    return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
}

public func synced(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

public func +=<K, V> ( left: inout [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }

public func +<K, V> (left: [K : V], right: [K : V]) -> [K : V]{var new = [K : V](); for (k, v) in  left { new[k] = v }; for (k, v) in  right { new[k] = v }; return new }

public func -<K, V: Comparable> (left: [K : V], right: [K : V]) -> [K : V]{var new = [K : V](); for (k, v) in  left { new[k] = v }; for (k,v) in right { if let n = new[k] , n == v { new.removeValue(forKey: k)}}; return new }

public func -<K, V> (left: [K : V], right: [K]) -> [K : V]{var new = [K : V](); for (k, v) in  left { new[k] = v }; for k in right {  new.removeValue(forKey: k)}; return new }

public func -=<K, V: Comparable> ( left: inout [K : V], right: [K : V]){for (k,v) in right { if let n = left[k] , n == v { left.removeValue(forKey: k)}}}

public func -=<K, V> ( left: inout [K : V], right: [K]) {for k in right { left.removeValue(forKey: k)}}

extension CLLocationCoordinate2D: Equatable {
    public func isZero() -> Bool {
        return self.latitude == 0.0 && self.longitude == 0.0
    }
}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension NSObject {
    public var className: String {
        return self.classForCoder.className
    }
    
    public static var className: String {
        return String(describing: self)
    }
}

extension UIColor {
    public convenience init(hex: UInt32, alpha: Float = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
    
    public class func hex(_ hex: UInt32) -> UIColor {
        return UIColor.init(hex: hex)
    }
}

extension NSString {
    public func trimmed() -> NSString {
        return String(self).trimmed()
    }
    
    public func stringBetweenStrings(_ start: NSString, end: NSString) -> NSString? {
        return String(self).stringBetweenStrings(start, end: end)
    }
    
    public func fileName() -> NSString? {
        return URL(fileURLWithPath: self as String).pathExtension as NSString?
    }
    
    public func clearHtmlElements() -> NSString {
        return String(self).clearHtmlElements()
    }
    
    public func cleanWhitespaces() -> NSString {
        return String(self).cleanWhitespaces()
    }
    
    public func onlyDigits() -> NSString {
        return String(self).onlyDigits()
    }
    
    public func allRange() -> NSRange {
        return NSMakeRange(0, self.length)
    }
    
    public func sizeForMaxSize(_ textSize: CGSize, font: UIFont) -> CGSize {
        return String(self).sizeForMaxSize(textSize, font: font)
    }
    
    public func widthForHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        return String(self).widthForHeight(height, font: font)
    }
    
    public func heightForWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        return String(self).heightForWidth(width, font: font)
    }
}

extension String {
    public subscript(integerIndex: Int) -> Character {
        let index = characters.index(startIndex, offsetBy: integerIndex)
        return self[index]
    }
    
    public subscript(integerRange: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: integerRange.lowerBound)
        let end = characters.index(startIndex, offsetBy: integerRange.upperBound)
        let range = start..<end
        return self[range]
    }
    
    public var length: Int {
        return self.characters.count
    }
    
    public var capitalizeFirst: String {
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).capitalized)
        return result
    }
    
    public var lowercaseFirst: String {
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).lowercased())
        return result
    }
    
    /// Trims white space and new line characters
    public mutating func trim() {
        self = self.trimmed()
    }
    
    /// Trims white space and new line characters, returns a new string
    public func trimmed() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public var urlEncodedValue: String {
        let allowedSet = CharacterSet(charactersIn: "=\"#%/<>?@\\^`{|}&: ").inverted
        let escapedString = addingPercentEncoding(withAllowedCharacters: allowedSet)
        return escapedString ?? self
    }
    
    public var queryDictionary: [String: String] {
        let parameters = components(separatedBy: "&")
        var dictionary = [String: String]()
        for parameter in parameters {
            let keyValue = parameter.components(separatedBy: "=")
            if keyValue.count == 2 {
                if let key = keyValue[0].removingPercentEncoding,
                    let value = keyValue[1].removingPercentEncoding {
                    dictionary[key] = value
                }
            }
        }
        return dictionary
    }
    
    public func stringBetweenStrings(_ start: String, end: String) -> String? {
        let scanner = Scanner.init(string: self)
        scanner.charactersToBeSkipped = nil
        scanner.scanUpTo(start, into: nil)
        if (scanner.scanString(start, into: nil)) {
            var result: NSString?
            if (scanner.scanUpTo(end, into: &result)) {
                return String(result!)
            }
        }
        return nil
    }
    
    public func fileName() -> String? {
        return URL(fileURLWithPath: self).pathExtension
    }
    
    public func clearHtmlElements() -> String {
        let replacements = ["&amp;":"&",
                            "&#039;":"'",
                            "&quot;":"\"",
                            "&lt;":"<",
                            "&gt;":">"]
        
        var string = self
        for (key, value) in replacements {
            string = string.replacingOccurrences(of: key, with: value)
        }
        return string
    }
    
    public func cleanWhitespaces() -> String {
        do {
            let regex = try NSRegularExpression.init(pattern: "\\s\\s+/", options: .caseInsensitive)
            let string = regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(), range: self.allRange(), withTemplate: " ")
            return string.trimmed()
        } catch {
            return self
        }
    }
    
    public func onlyDigits() -> String {
        return self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: self.rangeFromNSRange(self.allRange()))
    }
    
    public func allRange() -> NSRange {
        return NSMakeRange(0, self.length)
    }
    
    public func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
        let utf16view = utf16
        if let from16 = utf16view.index(utf16view.startIndex, offsetBy: nsRange.location, limitedBy: utf16view.endIndex) {
            if let to16 = utf16view.index(from16, offsetBy: nsRange.length, limitedBy: utf16view.endIndex) {
                if let from = String.Index(from16, within: self),
                    let to = String.Index(to16, within: self) {
                    return from ..< to
                }
            }
        }
        return nil
    }
    
    public func NSRangeFromRange(_ range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
        let to = String.UTF16View.Index(range.upperBound, within: utf16view)
        let range = NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from), utf16view.distance(from: from, to: to))
        return range
    }
    
    public func sizeForMaxSize(_ textSize: CGSize, font: UIFont) -> CGSize {
        var result = CGSize(width: 0, height: font.lineHeight)
        if (self.length > 0) {
            let attributes = [NSFontAttributeName:font]
            let frame = NSString.init(string: self).boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            result = frame.size
        }
        return result
    }
    
    public func widthForHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        return self.sizeForMaxSize(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), font: font).width
    }
    
    public func heightForWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        return self.sizeForMaxSize(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), font: font).height
    }
}

public extension NSArray {
    public func toString() -> String {
        var string = ""
        for (_, str) in self.enumerated() {
            string += "\(str),"
        }
        if (string.length > 0) {
            string.removeSubrange(string.rangeFromNSRange(NSMakeRange(string.length - 1, 1))!)
        }
        return string
    }
}

public extension NSMutableArray {
    public func moveObject(_ fromIndex: Int, toIndex: Int) {
        let object = self[fromIndex]
        self.removeObject(at: fromIndex)
        self.insert(object, at: toIndex)
    }
}

public extension URL {
    public func URLByAppendingQueryString(_ queryString: String) -> URL {
        if !queryString.isEmpty {
            let delimiter = (self.query == nil ? "?" : "&")
            let URLString = "\(self.absoluteString)\(delimiter)\(queryString)"
            if let URL = URL(string: URLString) {
                return URL
            }
        }
        return self
    }
}

public extension Array {
    public var jsonString: String {
        do {
            let stringData = try JSONSerialization.data(withJSONObject: self as AnyObject, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let string = String(data: stringData, encoding: String.Encoding.utf8) {
                return string
            }
        } catch _ {
            
        }
        return ""
    }
}

public extension Dictionary {
    public var queryString: String {
        let parts = map({(key, value) -> String in
            let keyStr = "\(key)"
            let valueStr = "\(value)"
            return "\(keyStr)=\(valueStr.urlEncodedValue)"
        })
        return parts.joined(separator: "&")
    }
    
    public var jsonString: String {
        do {
            let stringData = try JSONSerialization.data(withJSONObject: self as AnyObject, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let string = String(data: stringData, encoding: String.Encoding.utf8) {
                return string
            }
        } catch _ {
            
        }
        return ""
    }
}

public extension NSAttributedString {
    public func sizeWithMaxSize(_ size: CGSize) -> CGSize {
        return self.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
    }
    
    public class func image(_ image: UIImage) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        return NSAttributedString(attachment: attachment)
    }
}

extension NSRange {
    
    init(location:Int, length:Int) {
        self.location = location
        self.length = length
    }
    
    init(_ location:Int, _ length:Int) {
        self.location = location
        self.length = length
    }
    
    init(range:Range <Int>) {
        self.location = range.lowerBound
        self.length = range.upperBound - range.lowerBound
    }
    
    init(_ range:Range <Int>) {
        self.location = range.lowerBound
        self.length = range.upperBound - range.lowerBound
    }
    
    var startIndex:Int { get { return location } }
    var endIndex:Int { get { return location + length } }
    var asRange:CountableRange<Int> { get { return location..<location + length } }
    var isEmpty:Bool { get { return length == 0 } }
    
    func contains(_ index:Int) -> Bool {
        return index >= location && index < endIndex
    }
}

public extension Bool {
    public var stringValue: String {
        return self ? "1" : "0"
    }
}

public extension NSNumber {
    public func priceValue() -> String {
        let priceFormatter = NumberFormatter.init()
        priceFormatter.numberStyle = .currency
        priceFormatter.currencyCode = "USD"
        priceFormatter.currencySymbol = "$"
        priceFormatter.maximumFractionDigits = 2
        priceFormatter.locale = Locale.init(identifier: "en_US")
        
        let isInteger = fmod(self.floatValue, 1.0) == 0
        if (isInteger) {
            priceFormatter.maximumFractionDigits = 0
        }
        return priceFormatter.string(from: self)!
    }
}

public extension Date {
    
    public func stringWithFormat(_ dateFormat: String, enLocale: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if (enLocale) {
            dateFormatter.locale = Locale(identifier: "en_US")
        }
        return dateFormatter.string(from: self)
    }
    
    public static func dateFromString(_ dateString: String, dateFormat: String, enLocale: Bool = true) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if (enLocale) {
            dateFormatter.locale = Locale(identifier: "en_US")
        }
        return dateFormatter.date(from: dateString)!
    }
    
    public func isBetweenDates(_ startDate: Date, endDate: Date) -> Bool {
        return self.compare(startDate) != .orderedAscending && self.compare(endDate) != .orderedDescending
    }

    public func isTheSameDay(_ date: Date) -> Bool {
        let components: NSCalendar.Unit = [.year, .month, .day]
        let selfDay = (Calendar.current as NSCalendar).components(components, from: self)
        let otherDay = (Calendar.current as NSCalendar).components(components, from: date)
        if (selfDay.day == otherDay.day && selfDay.month == otherDay.month && selfDay.year == otherDay.year) {
            return true
        } else {
            return false
        }
    }
    
    public func isToday() -> Bool {
        return self.isTheSameDay(Date())
    }
    
    public func isYesterday() -> Bool {
        return self.isTheSameDay(Date().addingTimeInterval(-24 * 3600))
    }
}

public extension UIImage {
    
    public func tintColor(_ tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        // image drawing code here
        context?.setBlendMode(CGBlendMode.normal)
        context?.draw(self.cgImage!, in: rect)
        
        // draw tint color, preserving alpha values of original image
        context?.setBlendMode(CGBlendMode.sourceIn);
        tintColor.setFill()
        context?.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!
    }
    
    public func scaledToSize(_ size: CGSize, scale: Float = 0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    public func scaledToFitSize(_ size: CGSize, scale: Float = 0) -> UIImage {
        let aspect = self.size.width / self.size.height;
        var imageSize = CGSize.zero
        if (size.width / aspect <= size.height) {
            imageSize = CGSize(width: size.width, height: size.width / aspect)
        } else {
            imageSize = CGSize(width: size.height * aspect, height: size.height)
        }
        return self.scaledToSize(imageSize, scale: scale)
    }
    
    public func cropToSquare() -> UIImage {
        
        var cropSquare = CGRect.zero
        
        let edge = fmin(self.size.width, self.size.height)
        var posX = (self.size.width - edge) / 2
        var posY = (self.size.height - edge) / 2
        
        if (fmod(posX, CGFloat(1.0)) == 0) {
            posX = ceil(posX)
        }
        if (fmod(posY, CGFloat(1.0)) == 0) {
            posY = ceil(posY)
        }
        
        if (self.imageOrientation == UIImageOrientation.left || self.imageOrientation == .right) {
            cropSquare = CGRect(x: posY, y: posX, width: edge, height: edge)
        } else {
            cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
        }
        
        let imageRef = self.cgImage!.cropping(to: cropSquare)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    public class func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        var imageSize = size
        if (imageSize.width == 0) {
            imageSize.width = 1
        }
        if (imageSize.height == 0) {
            imageSize.height = 1
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }
    
    public func applyAlpha(_ alpha: Float) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        context?.scaleBy(x: 1, y: -1);
        context?.translateBy(x: 0, y: -rect.size.height);
        context?.setAlpha(CGFloat(alpha));
        context?.draw(self.cgImage!, in: rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    public func applyLightEffect() -> UIImage? {
        return applyBlurWithRadius(30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8)
    }
    
    public func applyExtraLightEffect() -> UIImage? {
        return applyBlurWithRadius(20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8)
    }
    
    public func applyDarkEffect() -> UIImage? {
        return applyBlurWithRadius(20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8)
    }
    
    public func applyTintEffectWithColor(_ tintColor: UIColor) -> UIImage? {
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor
        
        let componentCount = tintColor.cgColor.numberOfComponents
        
        if componentCount == 2 {
            var b: CGFloat = 0
            if tintColor.getWhite(&b, alpha: nil) {
                effectColor = UIColor(white: b, alpha: effectColorAlpha)
            }
        } else {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            
            if tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
                effectColor = UIColor(red: red, green: green, blue: blue, alpha: effectColorAlpha)
            }
        }
        
        return applyBlurWithRadius(10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
    
    public func applyBlurWithRadius(_ blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if (size.width < 1 || size.height < 1) {
            print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if self.cgImage == nil {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if maskImage != nil && maskImage!.cgImage == nil {
            print("*** error: maskImage must be backed by a CGImage: \(maskImage)")
            return nil
        }
        
        let __FLT_EPSILON__ = CGFloat(FLT_EPSILON)
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: CGPoint.zero, size: size)
        var effectImage = self
        
        let hasBlur = blurRadius > __FLT_EPSILON__
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__
        
        if hasBlur || hasSaturationChange {
            func createEffectBuffer(_ context: CGContext?) -> vImage_Buffer {
                let data = context?.data
                let width = vImagePixelCount((context?.width)!)
                let height = vImagePixelCount((context?.height)!)
                let rowBytes = context?.bytesPerRow
                
                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes!)
            }
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectInContext = UIGraphicsGetCurrentContext()
            
            effectInContext?.scaleBy(x: 1.0, y: -1.0)
            effectInContext?.translateBy(x: 0, y: -size.height)
            effectInContext?.draw(self.cgImage!, in: imageRect)
            
            var effectInBuffer = createEffectBuffer(effectInContext)
            
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectOutContext = UIGraphicsGetCurrentContext()
            
            var effectOutBuffer = createEffectBuffer(effectOutContext)
            
            
            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                
                let inputRadius = blurRadius * screenScale
                let sqrtValue = CGFloat(sqrt(2 * M_PI)) / 4
                let radiusValue = inputRadius * 3.0 * sqrtValue
                var radius = UInt32(floor(radiusValue + 0.5))
                if radius % 2 != 1 {
                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
                }
                
                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
                
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            }
            
            var effectImageBuffersAreSwapped = false
            
            if hasSaturationChange {
                let s: CGFloat = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1
                ]
                
                let divisor: CGFloat = 256
                let matrixSize = floatingPointSaturationMatrix.count
                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
                
                for i: Int in 0 ..< matrixSize {
                    saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
                }
                
                if hasBlur {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true
                } else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                }
            }
            
            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            
            UIGraphicsEndImageContext()
            
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            
            UIGraphicsEndImageContext()
        }
        
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext?.scaleBy(x: 1.0, y: -1.0)
        outputContext?.translateBy(x: 0, y: -size.height)
        
        // Draw base image.
        outputContext?.draw(self.cgImage!, in: imageRect)
        
        // Draw effect image.
        if hasBlur {
            outputContext?.saveGState()
            if let image = maskImage {
                outputContext?.clip(to: imageRect, mask: image.cgImage!);
            }
            outputContext?.draw(effectImage.cgImage!, in: imageRect)
            outputContext?.restoreGState()
        }
        
        // Add in color tint.
        if let color = tintColor {
            outputContext?.saveGState()
            outputContext?.setFillColor(color.cgColor)
            outputContext?.fill(imageRect)
            outputContext?.restoreGState()
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}

