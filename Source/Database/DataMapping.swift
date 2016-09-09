//
//  DataMapping.swift
//  Pods
//
//  Created by Vlad Getman on 31.05.16.
//
//

import Foundation
import CoreData
import FastEasyMapping

public class DataMapping<T: NSManagedObject where T: MappingProtocol>: FEMMapping {
    
    public var type: T.Type
    
    public required init(type: T.Type) {
        self.type = type
        super.init(entityName: String(T))
        if T.primaryKey() != "_" {
            self.primaryKey = T.primaryKey()
        }
    }
    
    public func addNumberAttributes(attributes: [String : String]) {
        for (property, path) in attributes {
            let attribute = FEMAttribute.init(property: property, keyPath: path, map: { (value) -> AnyObject? in
                if let number = value as? NSNumber {
                    return number
                } else if let string = value as? String {
                    let formatter = NSNumberFormatter()
                    formatter.locale = NSLocale(localeIdentifier: "en_US")
                    formatter.numberStyle = .DecimalStyle
                    let number = formatter.numberFromString(string)
                    return number
                }
                return nil
                }, reverseMap: nil)
            self.addAttribute(attribute)
        }
    }
    
    public func addDateAttribute(property: String, keyPath: String) {
        self.addAttribute(FEMAttribute.mappingOfProperty(property, toKeyPath: keyPath, dateFormat: "yyyy-MM-dd HH:mm:ss"))
    }
}