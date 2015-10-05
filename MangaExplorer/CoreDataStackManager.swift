//
//  CoreDataStackManager.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/26/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import CoreData

let SQLITE_FILE_NAME = "MangaExplorer.sqlite"
let CORE_DATA_MODEL_NAME = "MangaExplorer"

class CoreDataStackManager: NSObject {
    
    static let sharedInstance = CoreDataStackManager()
        
    lazy var applicationDocumentDirectory: NSURL = {
        let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as! NSURL
        return url
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(CORE_DATA_MODEL_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        var error: NSError? = nil
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to init perisistent coordinator"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error adding a persistent store type"
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "MangaExplorer", code: 9999, userInfo: dict as [NSObject:AnyObject])
            NSLog("CoreDataStackManager persistentStoreCoordinator error \(error), \(error?.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        if persistentStoreCoordinator == nil {
            return nil
        }
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        if let context = self.managedObjectContext {
            var error: NSError? = nil
            if context.hasChanges && !context.save(&error) {
                NSLog("CoreDataStackManager saveContext error \(error), \(error?.userInfo)")
                abort()
            }
        }
    }

}