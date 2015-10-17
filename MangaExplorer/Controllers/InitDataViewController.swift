//
//  InitDataViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class InitDataViewController: UIViewController {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    let backgroundQueue = dispatch_queue_create("MangaExplorerInitData", DISPATCH_QUEUE_SERIAL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var animationImages: [UIImage]?
        animationImages = [
            UIImage(named: "dogWaggingTailOrig")!,
            UIImage(named: "dogWaggingTailRight")!,
            UIImage(named: "dogWaggingTailOrig")!,
            UIImage(named: "dogWaggingTailLeft")!
        ]
        imageView.animationImages =  animationImages
        imageView.animationDuration = 0.1
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
        
        let progress = NSProgress(totalUnitCount: Int64(1))
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.Initial, context: nil)
        progress.becomeCurrentWithPendingUnitCount(Int64(1))
        
        insertAllMangaDetailsJSONDataInDB() {
            dispatch_async(dispatch_get_main_queue()) {
                progress.removeObserver(self, forKeyPath: "fractionCompleted")
                progress.resignCurrent()
                
                UserDefaults.sharedInstance.didInitDatabase = true
                NSNotificationCenter.defaultCenter().postNotificationName("performFetchForFetchedResultsControllerInTopRatedMangas", object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // MARK: - Data import
    
    private func insertAllMangaDetailsJSONDataInDB(completionHandler: ()->Void) {
        let progress = NSProgress(totalUnitCount: Int64(22))
        var counterForProgress = 0
        var counterForBatchSave = 0
        
        dispatch_async(backgroundQueue) {
            let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.ConfinementConcurrencyType)
            privateContext.persistentStoreCoordinator = CoreDataStackManager.sharedInstance.managedObjectContext!.persistentStoreCoordinator
            
            let jsonFileURL = NSBundle.mainBundle().URLForResource("Manga-Data", withExtension: "json")!
            if let jsonData = try? NSData(contentsOfURL: jsonFileURL, options: [NSDataReadingOptions.DataReadingMappedAlways, NSDataReadingOptions.DataReadingUncached]) {
                
                let jsonResults = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments)) as! [[String:AnyObject]]
                progress.completedUnitCount++
                
                let batchSize = jsonResults.count/20
                for mangaProperty in jsonResults {
                    
                    autoreleasepool {
                        let id = mangaProperty["id"] as? Int
                        let mangaTitle = mangaProperty["title"] as? String
                        let imageRemotePath = mangaProperty["imageRemotePath"] as? String
                        let bayesianAverage = mangaProperty["bayesianAverage"] as? Double
                        let plotSummary = mangaProperty["plotSummary"] as? String
                        let staff = mangaProperty["staff"] as? [[String:String]]
                        let alternativeTitles = mangaProperty["alternativeTitles"] as? [String]
                        let genres = mangaProperty["genres"] as? [String]
                        
                        if id != nil && mangaTitle != nil {
                            let manga = Manga(id: id!, title: mangaTitle!, context: privateContext)
                            if imageRemotePath != nil {
                                manga.imageRemotePath = imageRemotePath!
                            }
                            if bayesianAverage != nil {
                                manga.bayesianAverage = bayesianAverage!
                            }
                            if plotSummary != nil {
                                manga.plotSummary = plotSummary!
                            }
                            if staff != nil {
                                for staffMember in staff! {
                                    let task = staffMember["task"]
                                    let person = staffMember["person"]
                                    if task != nil && person != nil {
                                        if !task!.isEmpty && !person!.isEmpty {
                                            let staff = Staff(task: task!, person: person!, context: privateContext)
                                            staff.manga = manga
                                        }
                                    }
                                }
                            }
                            if alternativeTitles != nil {
                                for anAlternativeTitle: String in alternativeTitles! {
                                    let alternativeTitle = AlternativeTitle(title: anAlternativeTitle, context: privateContext)
                                    alternativeTitle.manga = manga
                                }
                            }
                            if genres != nil {
                                for aGenre: String in genres! {
                                    let genre = Genre(name: aGenre, context: privateContext)
                                    genre.manga = manga
                                }
                            }
                        }
                    }
                    
                    counterForBatchSave++
                    if counterForBatchSave >= 1000 {
                        counterForBatchSave = 0
                        do {
                            try privateContext.save()
                        } catch _ {
                        }
                    }
                    
                    counterForProgress++
                    if counterForProgress >= batchSize {
                        counterForProgress = 0
                        progress.completedUnitCount++
                    }
                }
                
                if progress.completedUnitCount < progress.totalUnitCount {
                    progress.completedUnitCount++
                }
                do {
                    try privateContext.save()
                } catch _ {
                }
                completionHandler()
            }
        }
    }
    
    // MARK: - NSProgress
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch keyPath! {
        case "fractionCompleted":
            NSOperationQueue.mainQueue().addOperationWithBlock {
                let progress = object as! NSProgress
                self.progressLabel.text = progress.localizedDescription
                self.progressView.progress = Float(progress.fractionCompleted)
            }
            return
        default:
            break
        }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }

}
