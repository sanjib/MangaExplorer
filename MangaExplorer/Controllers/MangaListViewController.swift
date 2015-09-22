//
//  MangaListViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/19/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class MangaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listSegmentedControl: UISegmentedControl!

    var selectedManga: Manga?
    var cache = NSCache()
    
    private let photoPlaceholderImage = UIImage(named: "mangaPlaceholder")
    
    struct ListSegmentedControlOption {
        static let WishList = 0
        static let FavoritesList = 1
    }
    var currentListType = 0
    
    // Core data
    let fetchBatchSize = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentListType = listSegmentedControl.selectedSegmentIndex
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Core data
        fetchedResultsController.delegate = self
        
        tableView.estimatedRowHeight = 62.0
        tableView.rowHeight = UITableViewAutomaticDimension

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchedResultsController.performFetch(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segmented control
    
    @IBAction func selectList(sender: UISegmentedControl) {
        currentListType = listSegmentedControl.selectedSegmentIndex
        
        switch self.currentListType {
        case ListSegmentedControlOption.WishList:
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "isWished == %@", true)
        case ListSegmentedControlOption.FavoritesList:
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "isFavorite == %@", true)
        default:
            break
        }
        
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
        
        println("current list type: \(self.currentListType)")
        
        switch self.currentListType {
        case ListSegmentedControlOption.WishList:
            fetchRequest.predicate = NSPredicate(format: "isWished == %@", true)
        case ListSegmentedControlOption.FavoritesList:
            fetchRequest.predicate = NSPredicate(format: "isFavorite == %@", true)
        default:
            break
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.fetchBatchSize = self.fetchBatchSize
        
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
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MangaListCell", forIndexPath: indexPath) as! MangaTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedManga = fetchedResultsController.objectAtIndexPath(indexPath) as? Manga
        performSegueWithIdentifier("MangaDetailsSegue", sender: self)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Configure cell
    
    func configureCell(cell: MangaTableViewCell, atIndexPath indexPath: NSIndexPath) {
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
                vc.mangaId = selectedManga?.id
            }
        }
    }

}
