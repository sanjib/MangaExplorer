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
    }
    
    
}