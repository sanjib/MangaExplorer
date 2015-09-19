//
//  Manga.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/26/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import CoreData

class Manga: NSManagedObject {
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var bayesianAverage: Double
    @NSManaged var imageRemotePath: String?
    @NSManaged var plotSummary: String?

    @NSManaged var isWished: Bool
    @NSManaged var isFavorite: Bool
    
    @NSManaged var staff: [Staff]
    @NSManaged var alternativeTitle: [AlternativeTitle]
    @NSManaged var genre: [Genre]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: Int, title: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Manga", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
        self.title = title

        isWished = false
        isFavorite = false
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
            if let imageName = url?.pathComponents?.last as? String {
                return imageName
            }
        }
        return nil
    }
    
    var localURL: NSURL? {
        let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as! NSURL
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