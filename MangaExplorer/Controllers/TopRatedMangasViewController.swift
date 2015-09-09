//
//  TopRatedViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class TopRatedMangasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellReuseIdentifier = "MangaCell"
    
    // Cell layout properties
    let cellsPerRowInPortraitMode: CGFloat = 3
    let cellsPerRowInLandscpaeMode: CGFloat = 6
    let minimumSpacingPerCell: CGFloat = 5
    
    private let photoPlaceholderImageData = NSData(data: UIImagePNGRepresentation(UIImage(named: "mangaPlaceholder")))
    
    private var selectedIndexes = [NSIndexPath]()
    private var insertedIndexPaths: [NSIndexPath]!
    private var deletedIndexPaths: [NSIndexPath]!
    private var updatedIndexPaths: [NSIndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

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
    
    // MARK: - CollectionView layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = minimumSpacingPerCell
        layout.minimumInteritemSpacing = minimumSpacingPerCell
        
        var width: CGFloat!
        if UIApplication.sharedApplication().statusBarOrientation.isLandscape == true {
            width = (CGFloat(collectionView.frame.size.width) / cellsPerRowInLandscpaeMode) - (minimumSpacingPerCell - (minimumSpacingPerCell / cellsPerRowInLandscpaeMode))
        } else {
            width = (CGFloat(collectionView.frame.size.width) / cellsPerRowInPortraitMode) - (minimumSpacingPerCell - (minimumSpacingPerCell / cellsPerRowInPortraitMode))
        }
        
        layout.itemSize = CGSize(width: width, height: (width*1.3) + 26)
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    // MARK: - CollectionView delegates
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MangaDetailsSegue", sender: self)
    }
    
    // MARK: - CollectionView data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TopRatedMangaCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    // MARK: - Configure cell
    
    func configureCell(cell: TopRatedMangaCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let manga = fetchedResultsController.objectAtIndexPath(indexPath) as! Manga
        
        cell.titleLabel.text = manga.title
        
        var author = ""
        for staff in manga.staff {
            if author.isEmpty {
                author = staff.person
            } else {
                author = author + ", " + staff.person
            }
            
        }
        cell.authorLabel.text = author

        
        // to round ratings to single digit precision, multiply by 10, round it, then divide by 10
        let ratings = Double(round(manga.bayesianAverage*10)/10)
        cell.ratingsLabel.text = "\(ratings)"
        
        if let imageData = manga.imageData {
            cell.activityIndicator.stopAnimating()
            cell.mangaImageView.image = UIImage(data: imageData)
        } else {
            cell.mangaImageView.image = UIImage(data: photoPlaceholderImageData)
            
            if manga.imageRemotePath != nil && manga.fetchInProgress == false {
                cell.activityIndicator.startAnimating()
                
                manga.fetchImageData { fetchComplete in
                    if fetchComplete == true {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadItemsAtIndexPaths([indexPath])
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsController delegates
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
