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

open class DataMapping<T: MappingProtocol>: FEMMapping {
    
    open var type: T.Type
    
    public required init(type: T.Type) {
        self.type = type
        super.init(entityName: String(describing: T.self))
        if T.primaryKey() != "_" {
            self.primaryKey = T.primaryKey()
        }
    }
    
    open func addNumberAttributes(_ attributes: [String: String]) {
        for (property, path) in attributes {
            let attribute = FEMAttribute(property: property, keyPath: path, map: { (value) -> AnyObject? in
                if let number = value as? NSNumber {
                    return number
                } else if let string = value as? String {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "en_US")
                    formatter.numberStyle = .decimal
                    let number = formatter.number(from: string)
                    return number
                }
                return nil
                }, reverseMap: nil)
            self.addAttribute(attribute)
        }
    }
    
    open func addDateAttribute(_ property: String, keyPath: String) {
        self.addAttribute(FEMAttribute.mapping(ofProperty: property, toKeyPath: keyPath, dateFormat: "yyyy-MM-dd HH:mm:ss"))
    }
}
