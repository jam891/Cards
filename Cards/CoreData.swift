//
//  CoreData.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/23/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    
    let managedObjectModel: NSManagedObjectModel
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    init(storeType: String, storeURL: NSURL?, schemaName: String, options: [NSObject: AnyObject]?) throws {
        let bundle = NSBundle(forClass: object_getClass(CoreData))
        var modelURL = bundle.URLForResource(schemaName, withExtension: "mom")
        if modelURL == nil {
            modelURL = bundle.URLForResource(schemaName, withExtension: "momd")
        }
        managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        try persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: options)
    }
    
    convenience init(sqliteDocumentName: String, schemaName: String) throws {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let storeURL = CoreData.applicationDocumentsDirectory().URLByAppendingPathComponent(sqliteDocumentName)
        
        // Load the existing database
        if !NSFileManager.defaultManager().fileExistsAtPath(storeURL.path!) {
            let sourceURLs = [
                NSBundle.mainBundle().URLForResource("Cards", withExtension: "db")!,
                NSBundle.mainBundle().URLForResource("Cards", withExtension: "db-wal")!,
                NSBundle.mainBundle().URLForResource("Cards", withExtension: "db-shm")!,
                ]
            let destURLs = [
                CoreData.applicationDocumentsDirectory().URLByAppendingPathComponent("Cards.db"),
                CoreData.applicationDocumentsDirectory().URLByAppendingPathComponent("Cards.db-wal"),
                CoreData.applicationDocumentsDirectory().URLByAppendingPathComponent("Cards.db-shm")
            ]
            for index in 0 ..< sourceURLs.count {
                do {
                    try NSFileManager.defaultManager().copyItemAtURL(sourceURLs[index], toURL: destURLs[index])
                } catch {
                    fatalError("Failure to load database: \(error)")
                }
            }
        }
        try self.init(storeType: NSSQLiteStoreType, storeURL: storeURL, schemaName: schemaName, options: options)
    }
    
    convenience init(inMemorySchemaName : String) throws {
        try self.init(storeType: NSInMemoryStoreType, storeURL: nil, schemaName: inMemorySchemaName, options: nil)
    }
    
    private class func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }
    
    func createManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }
    
}