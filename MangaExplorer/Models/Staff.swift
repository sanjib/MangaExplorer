//
//  Staff.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import CoreData

class Staff: NSManagedObject {
    @NSManaged var task: String
    @NSManaged var person: String
    @NSManaged var manga: Manga?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(task: String, person: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Staff", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.task = task
        self.person = person
    }
}