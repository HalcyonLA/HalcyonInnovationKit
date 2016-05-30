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

public class DataModel: NSObject {
    
    static let shared = DataModel()
    
    // MARK: - Core Data stack
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(AppName(), withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(AppName()).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            
            func reportAboutBadPersistentStore() {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                abort()
            }
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(url.path!)
                do {
                    try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
                } catch {
                    reportAboutBadPersistentStore()
                }
            } catch {
                reportAboutBadPersistentStore()
            }
            
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext()

        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
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
        if (NSThread.isMainThread()) {
            save()
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                save()
            })
        }
    }
    
    public class func saveContext() {
        DataModel.shared.saveContext()
    }
    
    // MARK: - Fetch
    
    public class func getEntity<T: NSManagedObject>(entity: T.Type, objectId: NSNumber) -> T? {
        let className = String(AnyObject.Type)
        let variable = "\(className.lowercaseFirst)Id"
        let predicate = NSPredicate.init(format: "(%K == %@)", variable, objectId)
        let items = DataModel.fetchEntity(entity, predicate: predicate)
        return items!.first as T?
    }
    
    public class func fetchEntity<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate?, descriptors: [NSSortDescriptor]? = nil) -> [T]? {
        let moc = DataModel.shared.managedObjectContext
        
        let fetch = NSFetchRequest.init()
        fetch.includesPendingChanges = true
        fetch.entity = NSEntityDescription.entityForName(String(AnyObject.Type), inManagedObjectContext: moc)
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = predicate
        fetch.sortDescriptors = descriptors
        
        do {
            let results = try moc.executeFetchRequest(fetch)
            return results as? [T]
        } catch {
            return nil
        }
    }
    
    public class func resetAllEntities<T: NSManagedObject>(entity: T.Type) {
        let moc = DataModel.shared.managedObjectContext
        
        let data = DataModel.fetchEntity(entity, predicate: nil)
        if (data != nil) {
            for (_, object) in data!.enumerate() {
                moc.deleteObject(object)
            }
        }
        do {
            try moc.save()
        } catch {
            
        }
    }
    
    public class func deleteObject(object: NSManagedObject) {
        let moc = object.managedObjectContext
        if (moc != nil) {
            moc!.deleteObject(object)
            do {
                try moc!.save()
            } catch {
                
            }
        }
    }
    
    // MARK: - Mapping
    
    public class func deserializeObject(object: [String : AnyObject]?, mapping: FEMMapping) -> AnyObject? {
        if (object == nil || object?.count == 0) {
            return nil
        }
        
        return FEMDeserializer.objectFromRepresentation(object!, mapping: mapping, context: DataModel.shared.managedObjectContext)
    }
    
    public class func deserializeArray(array: [AnyObject]?, mapping: FEMMapping) -> [AnyObject]? {
        if (array == nil || array?.count == 0) {
            return nil
        }
        
        return FEMDeserializer.collectionFromRepresentation(array!, mapping: mapping, context: DataModel.shared.managedObjectContext)
    }
}

// MARK: - NSManagedObject Subclass

public extension NSManagedObject {
    public func delete() {
        DataModel.deleteObject(self)
    }
    
    public class func fetch(objectId: NSNumber) -> Self? {
        return _fetch(objectId)
    }
    
    //helper for get correct object type
    private class func _fetch<T: NSManagedObject>(id: NSNumber) -> T? {
        return DataModel.getEntity(self, objectId: id) as? T
    }
}
