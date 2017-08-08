//
//  DataModel.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 25.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation
import CoreData
import FastEasyMapping
import XCGLogger

open class DataModel: NSObject {
    
    open static let shared = DataModel()
    open static var dbName = AppName()
    
    fileprivate var _managedObjectModel: NSManagedObjectModel?
    fileprivate var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    fileprivate var _managedObjectContext: NSManagedObjectContext?
    
    let log = XCGLogger.default
    
    // MARK: - Core Data stack
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    fileprivate var managedObjectModel: NSManagedObjectModel {
        get {
            if let moc = _managedObjectModel {
                return moc
            } else {
                // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
                let modelURL = Bundle.main.url(forResource: DataModel.dbName, withExtension: "momd")!
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
                return _managedObjectModel!
            }
        }
    }
    
    open var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        get {
            if let coordinator = _persistentStoreCoordinator {
                return coordinator
            } else {
                // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
                // Create the coordinator and store
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                let url = self.applicationDocumentsDirectory.appendingPathComponent("\(DataModel.dbName).sqlite")
                var failureReason = "There was an error creating or loading the application's saved data."
                do {
                    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
                } catch {
                    
                    func reportAboutBadPersistentStore() {
                        // Report any error we got.
                        var dict = [String: AnyObject]()
                        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
                        dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
                        
                        dict[NSUnderlyingErrorKey] = error as NSError
                        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                        // Replace this with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                        abort()
                    }
                    
                    do {
                        try FileManager.default.removeItem(atPath: url.path)
                        do {
                            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
                        } catch {
                            reportAboutBadPersistentStore()
                        }
                    } catch {
                        reportAboutBadPersistentStore()
                    }
                    
                }
                
                _persistentStoreCoordinator = coordinator
                return _persistentStoreCoordinator!
            }
        }
    }
    
    open var managedObjectContext: NSManagedObjectContext {
        get {
            if let moc = _managedObjectContext {
                return moc
            } else {
                /// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
                let coordinator = self.persistentStoreCoordinator
                let managedObjectContext = NSManagedObjectContext()
                
                managedObjectContext.persistentStoreCoordinator = coordinator
                _managedObjectContext = managedObjectContext
                return _managedObjectContext!
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    open func saveContext () {
        func save () {
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
        if Thread.isMainThread {
            save()
        } else {
            OperationQueue.main.addOperation({
                save()
            })
        }
    }
    
    open class func saveContext() {
        DataModel.shared.saveContext()
    }
    
    // MARK: - Fetch
    
    open class func getEntity<T: NSManagedObject>(_ entity: T.Type, objectId: NSNumber) -> T? where T: MappingProtocol {
        let predicate = NSPredicate(format: "(%K == %@)", T.primaryKey(), objectId)
        let items = DataModel.fetchEntity(entity, predicate: predicate)
        return items.first
    }
    
    open class func fetchEntity<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate?, descriptors: [NSSortDescriptor]? = nil) -> [T] {
        let moc = DataModel.shared.managedObjectContext
        
        let fetchRequest = NSFetchRequest<T>(entityName: "\(entity)")
        fetchRequest.includesPendingChanges = true
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "\(entity)", in: moc)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = descriptors
        
        do {
            let results = try moc.fetch(fetchRequest)
            return results
        } catch {
            return []
        }
    }
    
    open class func fetchEntity<T: NSManagedObject>(_ entity: T.Type, fetchModificate: (_ fetchRequest: NSFetchRequest<T>) -> Void) -> [T] {
        let moc = DataModel.shared.managedObjectContext
        
        let fetchRequest = NSFetchRequest<T>(entityName: "\(entity)")
        fetchRequest.includesPendingChanges = true
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "\(entity)", in: moc)
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchModificate(fetchRequest)
        
        do {
            let results = try moc.fetch(fetchRequest)
            return results
        } catch {
            return []
        }
    }
    
    open class func resetAll() {
        let model = DataModel.shared
        if let store = model.persistentStoreCoordinator.persistentStores.last {
            let storeURL = store.url!
            do {
                try model.persistentStoreCoordinator.remove(store)
                try FileManager.default.removeItem(at: storeURL)
                model._persistentStoreCoordinator = nil
                model._managedObjectContext = nil
                model._managedObjectModel = nil
                //called for reinitiate coordinator
                _ = model.persistentStoreCoordinator
            } catch {
                
            }
        }
    }
    
    open class func fetchAllEntities<T: NSManagedObject>(_ entity: T.Type) -> [T] {
        return fetchEntity(entity, predicate: nil)
    }
    
    open class func resetAllEntities<T: NSManagedObject>(_ entity: T.Type) {
        self.resetEntities(entity, predicate: nil)
    }
    
    open class func resetEntities<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate?) {
        let moc = DataModel.shared.managedObjectContext
        
        if #available(iOS 9.0, *) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(entity)")
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "\(entity)", in: moc)
            fetchRequest.predicate = predicate
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try moc.execute(deleteRequest)
            } catch let error as NSError {
                NSLog("resetEntities error: %@", error.localizedDescription)
            }
        } else {
            let data = DataModel.fetchEntity(entity, predicate: predicate)
            if data.count > 0 {
                for (_, object) in data.enumerated() {
                    moc.delete(object)
                }
                do {
                    try moc.save()
                } catch {
                    NSLog("resetEntities error: %@", error.localizedDescription)
                }
            }
        }
    }
    
    open class func deleteObject(_ object: NSManagedObject) {
        if let moc = object.managedObjectContext {
            moc.delete(object)
            do {
                try moc.save()
            } catch let error as NSError {
                NSLog("deleteObject error: %@", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Mapping
    
    @discardableResult
    open class func deserializeObject<T: NSManagedObject>(_ object: Any?, mapping: DataMapping<T>) -> T? {
        
        var convertedObject: [String : Any]?
        
        if let o = object as? NSDictionary {
            convertedObject = o as? [String : Any]
        } else if let o = object as? [String : Any] {
            convertedObject = o
        }
        
        if let obj = convertedObject {
            guard obj.count > 0 else {
                return nil
            }
            
            let cdObject = FEMDeserializer.object(fromRepresentation: obj, mapping: mapping, context: DataModel.shared.managedObjectContext)
            
            if let tObj = cdObject as? T {
                saveContext()
                return tObj
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    @discardableResult
    open class func deserializeArray<T: NSManagedObject>(_ array: Any?, mapping: DataMapping<T>) -> [T] {
        
        var convertedArray: [Any]?
        
        if let a = array as? NSArray {
            convertedArray = a as? [Any]
        } else if let a = array as? [Any] {
            convertedArray = a
        }
        
        if let collection = convertedArray {
            guard collection.count > 0 else {
                return []
            }
            
            let cdArray = FEMDeserializer.collection(fromRepresentation: collection, mapping: mapping, context: DataModel.shared.managedObjectContext)
            
            if let arr = cdArray as? [T] {
                saveContext()
                return arr
            } else {
                return []
            }
        } else {
            return []
        }
    }
}

// MARK: - NSManagedObject Subclass

public protocol MappingProtocol {
    /**
     If you don't need to use primary key - return "_"
     */
    static func primaryKey() -> String
}

extension MappingProtocol where Self: NSManagedObject {
    public static func fetch(_ objectId: NSNumber) -> Self? {
        return _fetch(objectId)
    }
    
    public static func fetch(_ objectId: Int64) -> Self? {
        return _fetch(NSNumber(value: objectId))
    }
    
    public static func fetch(_ objectId: Int16) -> Self? {
        return _fetch(NSNumber(value: objectId))
    }
    
    //helper for get correct object type
    fileprivate static func _fetch<T: NSManagedObject>(_ id: NSNumber) -> T? {
        return DataModel.getEntity(self, objectId: id) as? T
    }
}

public extension NSManagedObject {
    public func delete() {
        DataModel.deleteObject(self)
    }
    
    public static func resetAll() {
        DataModel.resetAllEntities(self.self)
    }
    
    public static func reset(_ predicate: NSPredicate) {
        DataModel.resetEntities(self.self, predicate: predicate)
    }
}
