//
//  MangaSearchViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/13/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class MangaSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    private var cache = NSCache()
    private var selectedManga: Manga?
    
    private let photoPlaceholderImage = UIImage(named: "mangaPlaceholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false

        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
        fetchedResultsController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Search
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text

        let predicateTitle = NSPredicate(format: "%K contains[cd] %@", "title", searchString)
        let predicateAuthor = NSPredicate(format: "%K contains[cd] %@", "staff.person", searchString)
        let predicateAlternativeTitle = NSPredicate(format: "%K contains[cd] %@", "alternativeTitle.title", searchString)
    
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(
            type: NSCompoundPredicateType.OrPredicateType,
            subpredicates: [predicateTitle, predicateAuthor, predicateAlternativeTitle])
        fetchedResultsController.performFetch(nil)
        println("fetched objects count: \(fetchedResultsController.fetchedObjects?.count)")
        tableView.reloadData()
    }
    
    // MARK: - Core data
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Manga")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bayesianAverage", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    
    // MARK: - TableView delegates & data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            if let sectionInfo =  sections[section] as? NSFetchedResultsSectionInfo {
                return sectionInfo.numberOfObjects
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MangaSearchResultCell", forIndexPath: indexPath) as! SearchResultTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedManga = fetchedResultsController.objectAtIndexPath(indexPath) as? Manga
        performSegueWithIdentifier("MangaDetailsSegue", sender: self)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! SearchResultTableViewCell
            configureCell(cell, atIndexPath: indexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Configure cell
    
    func configureCell(cell: SearchResultTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let manga = fetchedResultsController.objectAtIndexPath(indexPath) as! Manga
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
                                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
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
