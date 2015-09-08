//
//  TopRatedViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class TopRatedViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    private let numberOfMangaDetailsToFetchPerHTTPRequest = 480/2
    private var fetchedObjectsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // CoreData
        fetchedResultsController.delegate = self
        println("will perform fetch")
        fetchedResultsController.performFetch(nil)
        if let fetchedObjectsCount = fetchedResultsController.fetchedObjects?.count {
            self.fetchedObjectsCount = fetchedObjectsCount
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if fetchedObjectsCount == 0 {
            println("init data segue")
            performSegueWithIdentifier("InitDataSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("didReceiveMemoryWarning: TopRatedViewController")
    }
    
    // MARK: - CoreData
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Manga")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bayesianAverage", ascending: false)]
        fetchRequest.fetchBatchSize = 48
        fetchRequest.fetchLimit = self.fetchLimitForCurrentBatch()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    private func fetchLimitForCurrentBatch() -> Int {
        return fetchedObjectsCount + numberOfMangaDetailsToFetchPerHTTPRequest
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
