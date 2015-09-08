//
//  AlternativeTitle.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import CoreData

class AlternativeTitle: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var manga: Manga?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("AlternativeTitle", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = title
    }
}