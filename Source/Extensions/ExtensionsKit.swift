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

public func UIColorFromHex(hex: UInt32) -> UIColor {
    return UIColor.init(hex: hex)
}

public func UIColorFromHexWithAlpha(hex: UInt32, alpha: Float) -> UIColor {
    return UIColor.init(hex: hex, alpha: alpha)
}

public func AppName() -> String {
    return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
}

public func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }

public func +<K, V> (left: [K : V], right: [K : V]) -> [K : V]{var new = [K : V](); for (k, v) in  left { new[k] = v }; for (k, v) in  right { new[k] = v }; return new }

public func -<K, V: Comparable> (left: [K : V], right: [K : V]) -> [K : V]{var new = [K : V](); for (k, v) in  left { new[k] = v }; for (k,v) in right { if let n = new[k] where n == v { new.removeValueForKey(k)}}; return new }

public func -<K, V> (left: [K : V], right: [K]) -> [K : V]{var new = [K : V](); for (k, v) in  left { new[k] = v }; for k in right {  new.removeValueForKey(k)}; return new }

public func -=<K, V: Comparable> (inout left: [K : V], right: [K : V]){for (k,v) in right { if let n = left[k] where n == v { left.removeValueForKey(k)}}}

public func -=<K, V> (inout left: [K : V], right: [K]) {for k in right { left.removeValueForKey(k)}}

extension NSObject {
    public var className: String {
        return self.classForCoder.className
    }
    
    public static var className: String {
        return String(self)
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
    
    public class func hex(hex: UInt32) -> UIColor {
        return UIColor.init(hex: hex)
    }
}

extension NSString {
    public func trimmed() -> NSString {
        return String(self).trimmed()
    }
    
    public func stringBetweenStrings(start: NSString, end: NSString) -> NSString? {
        return String(self).stringBetweenStrings(start, end: end)
    }
    
    public func fileName() -> NSString? {
        return NSURL(fileURLWithPath: self as String).pathExtension
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
    
    public func sizeForMaxSize(textSize: CGSize, font: UIFont) -> CGSize {
        return String(self).sizeForMaxSize(textSize, font: font)
    }
    
    public func widthForHeight(height: CGFloat, font: UIFont) -> CGFloat {
        return String(self).widthForHeight(height, font: font)
    }
    
    public func heightForWidth(width: CGFloat, font: UIFont) -> CGFloat {
        return String(self).heightForWidth(width, font: font)
    }
}

extension String {
    public subscript(integerIndex: Int) -> Character {
        let index = startIndex.advancedBy(integerIndex)
        return self[index]
    }
    
    public subscript(integerRange: Range<Int>) -> String {
        let start = startIndex.advancedBy(integerRange.startIndex)
        let end = startIndex.advancedBy(integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
    
    public var length: Int {
        return self.characters.count
    }
    
    public var capitalizeFirst: String {
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }
    
    public var lowercaseFirst: String {
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).lowercaseString)
        return result
    }
    
    /// Trims white space and new line characters
    public mutating func trim() {
        self = self.trimmed()
    }
    
    /// Trims white space and new line characters, returns a new string
    public func trimmed() -> String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).joinWithSeparator("")
    }
    
    public var urlEncodedValue: String {
        let allowedSet = NSCharacterSet(charactersInString: "=\"#%/<>?@\\^`{|}&: ").invertedSet
        let escapedString = stringByAddingPercentEncodingWithAllowedCharacters(allowedSet)
        return escapedString ?? self
    }
    
    public var queryDictionary: [String: String] {
        let parameters = componentsSeparatedByString("&")
        var dictionary = [String: String]()
        for parameter in parameters {
            let keyValue = parameter.componentsSeparatedByString("=")
            if keyValue.count == 2 {
                if let key = keyValue[0].stringByRemovingPercentEncoding,
                    value = keyValue[1].stringByRemovingPercentEncoding {
                    dictionary[key] = value
                }
            }
        }
        return dictionary
    }
    
    public func stringBetweenStrings(start: String, end: String) -> String? {
        let scanner = NSScanner.init(string: self)
        scanner.charactersToBeSkipped = nil
        scanner.scanUpToString(start, intoString: nil)
        if (scanner.scanString(start, intoString: nil)) {
            var result: NSString?
            if (scanner.scanUpToString(end, intoString: &result)) {
                return String(result)
            }
        }
        return nil
    }
    
    public func fileName() -> String? {
        return NSURL(fileURLWithPath: self).pathExtension
    }
    
    public func clearHtmlElements() -> String {
        let replacements = ["&amp;":"&",
                            "&#039;":"'",
                            "&quot;":"\"",
                            "&lt;":"<",
                            "&gt;":">"]
        
        var string = self
        for (key, value) in replacements {
            string = string.stringByReplacingOccurrencesOfString(key, withString: value)
        }
        return string
    }
    
    public func cleanWhitespaces() -> String {
        do {
            let regex = try NSRegularExpression.init(pattern: "  +", options: .CaseInsensitive)
            let string = regex.stringByReplacingMatchesInString(self, options: NSMatchingOptions(), range: self.allRange(), withTemplate: " ")
            return string.trimmed()
        } catch {
            return self
        }
    }
    
    public func onlyDigits() -> String {
        return self.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: self.rangeFromNSRange(self.allRange()))
    }
    
    public func allRange() -> NSRange {
        return NSMakeRange(0, self.length)
    }
    
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }
    
    public func sizeForMaxSize(textSize: CGSize, font: UIFont) -> CGSize {
        var result = CGSizeMake(0, font.lineHeight)
        if (self.length > 0) {
            let attributes = [NSFontAttributeName:font]
            let frame = NSString.init(string: self).boundingRectWithSize(textSize, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            result = frame.size
        }
        return result
    }
    
    public func widthForHeight(height: CGFloat, font: UIFont) -> CGFloat {
        return self.sizeForMaxSize(CGSizeMake(CGFloat.max, height), font: font).width
    }
    
    public func heightForWidth(width: CGFloat, font: UIFont) -> CGFloat {
        return self.sizeForMaxSize(CGSizeMake(width, CGFloat.max), font: font).height
    }
}

public extension NSArray {
    public func toString() -> String {
        var string = ""
        for (_, str) in self.enumerate() {
            string += "\(str),"
        }
        if (string.length > 0) {
            string.removeRange(string.rangeFromNSRange(NSMakeRange(string.length - 1, 1))!)
        }
        return string
    }
}

public extension NSMutableArray {
    public func moveObject(fromIndex: Int, toIndex: Int) {
        let object = self[fromIndex]
        self.removeObjectAtIndex(fromIndex)
        self.insertObject(object, atIndex: toIndex)
    }
}

public extension NSURL {
    public func URLByAppendingQueryString(queryString: String) -> NSURL {
        if !queryString.isEmpty {
            let delimiter = (self.query == nil ? "?" : "&")
            let URLString = "\(self.absoluteString)\(delimiter)\(queryString)"
            if let URL = NSURL(string: URLString) {
                return URL
            }
        }
        return self
    }
}

public extension Dictionary {
    public var queryString: String {
        let parts = map({(key, value) -> String in
            let keyStr = "\(key)"
            let valueStr = "\(value)"
            return "\(keyStr)=\(valueStr.urlEncodedValue)"
        })
        return parts.joinWithSeparator("&")
    }
    
    public var jsonString: String {
        do {
            let stringData = try NSJSONSerialization.dataWithJSONObject(self as! AnyObject, options: NSJSONWritingOptions.PrettyPrinted)
            if let string = String(data: stringData, encoding: NSUTF8StringEncoding) {
                return string
            }
        } catch _ {
            
        }
        return ""
    }
}

public extension NSAttributedString {
    public func sizeWithMaxSize(size: CGSize) -> CGSize {
        return self.boundingRectWithSize(size, options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).size
    }
}

public extension NSNumber {
    public func priceValue() -> String {
        let priceFormatter = NSNumberFormatter.init()
        priceFormatter.numberStyle = .CurrencyStyle
        priceFormatter.currencyCode = "USD"
        priceFormatter.currencySymbol = "$"
        priceFormatter.maximumFractionDigits = 2
        priceFormatter.locale = NSLocale.init(localeIdentifier: "en_US")
        
        let isInteger = fmod(self.floatValue, 1.0) == 0
        if (isInteger) {
            priceFormatter.maximumFractionDigits = 0
        }
        return priceFormatter.stringFromNumber(self)!
    }
}

public extension NSDate {
    
    public func stringWithFormat(dateFormat: String, enLocale: Bool = true) -> String {
        let dateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        if (enLocale) {
            dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US")
        }
        return dateFormatter.stringFromDate(self)
    }
    
    public class func dateFromString(dateString: String, dateFormat: String, enLocale: Bool = true) -> NSDate {
        let dateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        if (enLocale) {
            dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US")
        }
        return dateFormatter.dateFromString(dateString)!
    }
    
    public func isBetweenDates(startDate: NSDate, endDate: NSDate) -> Bool {
        return self.compare(startDate) != .OrderedAscending && self.compare(endDate) != .OrderedDescending
    }

    public func isTheSameDay(date: NSDate) -> Bool {
        let components: NSCalendarUnit = [.Year, .Month, .Day]
        let selfDay = NSCalendar.currentCalendar().components(components, fromDate: self)
        let otherDay = NSCalendar.currentCalendar().components(components, fromDate: date)
        if (selfDay.day == otherDay.day && selfDay.month == otherDay.month && selfDay.year == otherDay.year) {
            return true
        } else {
            return false
        }
    }
    
    public func isToday() -> Bool {
        return self.isTheSameDay(NSDate())
    }
    
    public func isYesterday() -> Bool {
        return self.isTheSameDay(NSDate().dateByAddingTimeInterval(-24 * 3600))
    }
}

public extension UIImage {
    
    public func tintColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        
        // image drawing code here
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextDrawImage(context, rect, self.CGImage)
        
        // draw tint color, preserving alpha values of original image
        CGContextSetBlendMode(context, CGBlendMode.SourceIn);
        tintColor.setFill()
        CGContextFillRect(context, rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
    public func scaledToSize(size: CGSize, scale: Float = 0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func scaledToFitSize(size: CGSize, scale: Float = 0) -> UIImage {
        let aspect = self.size.width / self.size.height;
        var size = CGSizeZero
        if (size.width / aspect <= size.height) {
            size = CGSizeMake(size.width, size.width / aspect)
        } else {
            size = CGSizeMake(size.height * aspect, size.height)
        }
        return self.scaledToSize(size, scale: scale)
    }
    
    public func cropToSquare() -> UIImage {
        
        var cropSquare = CGRectZero
        
        let edge = fmin(self.size.width, self.size.height)
        var posX = (self.size.width - edge) / 2
        var posY = (self.size.height - edge) / 2
        
        if (fmod(posX, CGFloat(1.0)) == 0) {
            posX = ceil(posX)
        }
        if (fmod(posY, CGFloat(1.0)) == 0) {
            posY = ceil(posY)
        }
        
        if (self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == .Right) {
            cropSquare = CGRectMake(posY, posX, edge, edge)
        } else {
            cropSquare = CGRectMake(posX, posY, edge, edge)
        }
        
        let imageRef = CGImageCreateWithImageInRect(self.CGImage!, cropSquare)
        let image = UIImage.init(CGImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    public class func imageWithColor(color: UIColor, size: CGSize = CGSizeMake(1, 1)) -> UIImage {
        var imageSize = size
        if (imageSize.width == 0) {
            imageSize.width = 1
        }
        if (imageSize.height == 0) {
            imageSize.height = 1
        }
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    public func applyAlpha(alpha: Float) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -rect.size.height);
        CGContextSetAlpha(context, CGFloat(alpha));
        CGContextDrawImage(context, rect, self.CGImage);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
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
    
    public func applyTintEffectWithColor(tintColor: UIColor) -> UIImage? {
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor
        
        let componentCount = CGColorGetNumberOfComponents(tintColor.CGColor)
        
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
    
    public func applyBlurWithRadius(blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if (size.width < 1 || size.height < 1) {
            print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if self.CGImage == nil {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if maskImage != nil && maskImage!.CGImage == nil {
            print("*** error: maskImage must be backed by a CGImage: \(maskImage)")
            return nil
        }
        
        let __FLT_EPSILON__ = CGFloat(FLT_EPSILON)
        let screenScale = UIScreen.mainScreen().scale
        let imageRect = CGRect(origin: CGPointZero, size: size)
        var effectImage = self
        
        let hasBlur = blurRadius > __FLT_EPSILON__
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__
        
        if hasBlur || hasSaturationChange {
            func createEffectBuffer(context: CGContext?) -> vImage_Buffer {
                let data = CGBitmapContextGetData(context)
                let width = vImagePixelCount(CGBitmapContextGetWidth(context))
                let height = vImagePixelCount(CGBitmapContextGetHeight(context))
                let rowBytes = CGBitmapContextGetBytesPerRow(context)
                
                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
            }
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectInContext = UIGraphicsGetCurrentContext()
            
            CGContextScaleCTM(effectInContext, 1.0, -1.0)
            CGContextTranslateCTM(effectInContext, 0, -size.height)
            CGContextDrawImage(effectInContext, imageRect, self.CGImage)
            
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
                var radius = UInt32(floor(inputRadius * 3.0 * CGFloat(sqrt(2 * M_PI)) / 4 + 0.5))
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
                var saturationMatrix = [Int16](count: matrixSize, repeatedValue: 0)
                
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
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
            
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
        }
        
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        let outputContext = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(outputContext, 1.0, -1.0)
        CGContextTranslateCTM(outputContext, 0, -size.height)
        
        // Draw base image.
        CGContextDrawImage(outputContext, imageRect, self.CGImage)
        
        // Draw effect image.
        if hasBlur {
            CGContextSaveGState(outputContext)
            if let image = maskImage {
                CGContextClipToMask(outputContext, imageRect, image.CGImage);
            }
            CGContextDrawImage(outputContext, imageRect, effectImage.CGImage)
            CGContextRestoreGState(outputContext)
        }
        
        // Add in color tint.
        if let color = tintColor {
            CGContextSaveGState(outputContext)
            CGContextSetFillColorWithColor(outputContext, color.CGColor)
            CGContextFillRect(outputContext, imageRect)
            CGContextRestoreGState(outputContext)
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}

