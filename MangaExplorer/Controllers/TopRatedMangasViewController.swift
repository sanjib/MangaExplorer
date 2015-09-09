//
//  TopRatedViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class TopRatedMangasViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // CoreData
        fetchedResultsController.delegate = self
        println("will perform fetch")
        fetchedResultsController.performFetch(nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "performFetchForFetchedResultsController", name: "performFetchForFetchedResultsControllerInTopRatedMangas", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Init data if manga table is empty
        if fetchedResultsController.fetchedObjects?.count == 0 {
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
        fetchRequest.fetchBatchSize = 12
        fetchRequest.fetchLimit = 480/2
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    
    // For post notification from InitViewController
    func performFetchForFetchedResultsController() {
        fetchedResultsController.performFetch(nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
