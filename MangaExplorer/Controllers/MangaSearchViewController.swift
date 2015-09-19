//
//  MangaSearchViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/13/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class MangaSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchController: UISearchController!

    private var cache = NSCache()
    private var searchResults = [Manga]()
    private var selectedManga: Manga?
    private var fetchInProgressCount = 0
    private let photoPlaceholderImage = UIImage(named: "mangaPlaceholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()

        // Search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
        tableView.estimatedRowHeight = 62.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Search
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        if !searchString.isEmpty || searchResults.count > 0 {
            activityIndicator.startAnimating()
            fetchMangas(searchString)
        }
    }
    
    // MARK: - Core data
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }
    
    var privateContext: NSManagedObjectContext {
        let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = CoreDataStackManager.sharedInstance.managedObjectContext!.persistentStoreCoordinator
        return privateContext
    }
    
    func fetchMangas(searchString: String) {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Manga", inManagedObjectContext: sharedContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bayesianAverage", ascending: false)]
        fetchRequest.fetchBatchSize = 16
        
        let predicateTitle = NSPredicate(format: "%K contains[cd] %@", "title", searchString)
        let predicateAuthor = NSPredicate(format: "%K contains[cd] %@", "staff.person", searchString)
        let predicateAlternativeTitle = NSPredicate(format: "%K contains[cd] %@", "alternativeTitle.title", searchString)
        
        fetchRequest.predicate = NSCompoundPredicate(
            type: NSCompoundPredicateType.OrPredicateType,
            subpredicates: [predicateTitle, predicateAuthor, predicateAlternativeTitle])
        
        fetchInProgressCount++
        privateContext.performBlock() {
            var error: NSError? = nil
            var results =  self.privateContext.executeFetchRequest(fetchRequest, error: &error)
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                if let error = error {
                    self.searchResults = [Manga]()
                } else {
                    self.searchResults = results as! [Manga]
                }
                println("search results count: \(self.searchResults.count)")
                
                self.fetchInProgressCount--
                
                println("fetch in progress count: \(self.fetchInProgressCount)")
                
                if self.fetchInProgressCount == 0 {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - TableView delegates & data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MangaSearchResultCell", forIndexPath: indexPath) as! MangaTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let manga = searchResults.count > indexPath.row ? searchResults[indexPath.row] : nil {
            selectedManga = manga
            performSegueWithIdentifier("MangaDetailsSegue", sender: self)
        }
    }
    
    // MARK: - Configure cell
    
    func configureCell(cell: MangaTableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        if let manga = searchResults.count > indexPath.row ? searchResults[indexPath.row] : nil {
            println("configureCell found manga at: \(indexPath.row)")
            
            cell.titleLabel.text = manga.title
            
            var allAlternativeTitles = ""
            for alternativeTitle in manga.alternativeTitle {
                if allAlternativeTitles.isEmpty {
                    allAlternativeTitles = alternativeTitle.title
                } else {
                    allAlternativeTitles += ", " + alternativeTitle.title
                }
            }
            cell.alternativeTitlesLabel.text = allAlternativeTitles
            
            var allStaff = ""
            for staff in manga.staff {
                if allStaff.isEmpty {
                    allStaff = staff.person
                } else {
                    allStaff += ", " + staff.person
                }
            }
            cell.creatorsLabel.text = allStaff
            
            // if imageName: check in cache, else check if already downloaded, else fetch
            if let imageName = manga.imageName {
                if let image = cache.objectForKey(imageName) as? UIImage {
                    cell.mangaImageView.image = image
                } else {
                    if let imageData = manga.imageData {
                        let image = UIImage(data: imageData)!
                        cache.setObject(image, forKey: imageName)
                        cell.mangaImageView.image = image
                    } else {
                        cell.mangaImageView.image = photoPlaceholderImage
                        if !manga.fetchInProgress {
                            manga.fetchImageData { fetchComplete in
                                if fetchComplete {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.safeReloadMangaRowAtIndexPath(indexPath, manga: manga)
                                        NSNotificationCenter.defaultCenter().postNotificationName("refreshMangaImageNotification", object: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                cell.mangaImageView.image = photoPlaceholderImage
            }
        }
    }
    
    private func safeReloadMangaRowAtIndexPath(indexPath: NSIndexPath, manga: Manga) {
        if let mangaInSearchResults = searchResults.count > indexPath.row ? searchResults[indexPath.row] : nil {
            if mangaInSearchResults.id == manga.id {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MangaDetailsSegue" {
            if selectedManga != nil {
                let vc = segue.destinationViewController as! MangaDetailsViewController
                vc.manga = selectedManga!
            }
        }
    }

}
