//
//  Character.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 10/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import CoreData

class Character: NSManagedObject {
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var imageRemotePath: String?
    @NSManaged var manga: Manga?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(firstName: String, lastName: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Character", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var fetchInProgress = false
    
    var didFetchImageData: Bool {
        if let localURL = localURL {
            if NSFileManager.defaultManager().fileExistsAtPath(localURL.path!) {
                return true
            }
        }
        return false
    }
    
    var imageName: String? {
        if let imageRemotePath = imageRemotePath {
            let url = NSURL(string: imageRemotePath)
            if let imageName = url?.pathComponents?.last {
                return "aniListCharacter" + imageName
            }
        }
        return nil
    }
    
    var localURL: NSURL? {
        let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        if let imageName = imageName {
            return url.URLByAppendingPathComponent(imageName)
        }
        return nil
    }
    
    var imageData: NSData? {
        var imageData: NSData? = nil
        if let localURL = localURL {
            if NSFileManager.defaultManager().fileExistsAtPath(localURL.path!) {
                imageData = NSData(contentsOfURL: localURL)
            }
        }
        return imageData
    }
    
    func fetchImageData(completionHandler: (fetchComplete: Bool) -> Void) {
        if didFetchImageData == false && fetchInProgress == false {
            fetchInProgress = true
            if let localURL = localURL {
                if let imageRemotePath = imageRemotePath {
                    if let url = NSURL(string: imageRemotePath) {
                        NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
                            if self.managedObjectContext != nil {
                                if error != nil {
                                    completionHandler(fetchComplete: false)
                                } else {
                                    NSFileManager.defaultManager().createFileAtPath(localURL.path!, contents: data, attributes: nil)
                                }
                                completionHandler(fetchComplete: true)
                            } else {
                                completionHandler(fetchComplete: false)
                            }
                            self.fetchInProgress = false
                            }.resume()
                    }
                }
            }
        }
    }
}