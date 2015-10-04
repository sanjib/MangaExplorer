//
//  MangaDetailsViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class MangaDetailsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mangaImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alternativeTitleLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!
    @IBOutlet weak var bayesianAverageLabel: UILabel!
    @IBOutlet weak var plotSummaryLabel: UILabel!
    @IBOutlet weak var charactersLabel: UILabel!
    
    @IBOutlet weak var dataSourceLabel: UILabel!
    @IBOutlet weak var animeNewsNetworkButton: UIButton!
    @IBOutlet weak var aniListLabel: UILabel!
    
    @IBOutlet weak var addToWishListButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    
    var mangaId: NSNumber!
    private var manga: Manga!
//    var currentContext: NSManagedObjectContext!
    
    private let photoPlaceholderImage = UIImage(named: "mangaPlaceholder")
    
    private var attributesForHeading: [String:AnyObject] {
        let fontAttribute = UIFont(name: "Helvetica Neue", size: 16.0)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        let attributes = [
            NSFontAttributeName: fontAttribute,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        return attributes
    }
    
    private var attributesForStaffHeading: [String:AnyObject] {
        let fontAttribute = UIFont(name: "Helvetica Neue", size: 14.0)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        
        let attributes = [
            NSFontAttributeName: fontAttribute,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        return attributes
    }
    
    private var attributesForBody: [String:AnyObject] {
        let fontAttribute = UIFont(name: "Helvetica Neue", size: 14.0)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        
        let attributes = [
            NSFontAttributeName: fontAttribute,
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        return attributes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMangaImage", name: "refreshMangaImageNotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.charactersLabel.hidden = true
        
        manga = fetchManga()
        println("manga id: \(manga.id)")
        
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        AniListApi.sharedInstance.getCharacterDetails(manga.title) { characterDetails, errorString in
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            println("characterDetails: \(characterDetails)")
//            if characterDetails?.count > 0 {
//                println(characterDetails!)
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.charactersLabel.hidden = false
//                    
//                    var charactersAttributedString = NSMutableAttributedString(string: "Characters")
//                    charactersAttributedString.addAttributes(self.attributesForHeading, range: NSRange(location: 0, length: charactersAttributedString.length))
//                    let charactersHeaderEndLocation = charactersAttributedString.length
//                    
//                    for characterDetail in characterDetails! {
//                        charactersAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + characterDetail))
//                    }
//                    charactersAttributedString.addAttributes(self.attributesForBody, range: NSRange(location: charactersHeaderEndLocation, length: charactersAttributedString.length - charactersHeaderEndLocation))
//                    
//                    self.charactersLabel.attributedText = charactersAttributedString
//                }
//            }
//        }
        
        bayesianAverageLabel.layer.cornerRadius = 3.0
        bayesianAverageLabel.clipsToBounds = true
        
        setTitleForWishListButton()
        setTitleForFavoritesButton()
        
        setMangaImage()
        setTitle()
        setStaff()
        setBayesianAverage()
        setPlotSummary()
        setAlternativeTitle()
    }
    
    // MARK: - CoreData
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }
    
    func fetchManga() -> Manga {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Manga", inManagedObjectContext: sharedContext)
        fetchRequest.predicate = NSPredicate(format: "id=%@", mangaId)
        
        var error: NSError? = nil
        var results = sharedContext.executeFetchRequest(fetchRequest, error: &error)
        if let error = error {
            return Manga()
        }
        return results?.first as! Manga
    }
    
    // MARK: - List buttons
    
    @IBAction func wishListAction(sender: AddToButton) {
        manga.isWished = !manga.isWished
        CoreDataStackManager.sharedInstance.saveContext()
        setTitleForWishListButton()
    }
    
    @IBAction func favoriteListAction(sender: AnyObject) {
        manga.isFavorite = !manga.isFavorite
        CoreDataStackManager.sharedInstance.saveContext()
        setTitleForFavoritesButton()
    }
    
    private func setTitleForWishListButton() {
        if manga.isWished {
            addToWishListButton.setTitle("Remove from Wish List", forState: UIControlState.Normal)
        } else {
            addToWishListButton.setTitle("Add to Wish List", forState: UIControlState.Normal)
        }
    }
    
    private func setTitleForFavoritesButton() {
        if manga.isFavorite {
            addToFavoritesButton.setTitle("Remove from Favorites", forState: UIControlState.Normal)
        } else {
            addToFavoritesButton.setTitle("Add to Favorites", forState: UIControlState.Normal)
        }
    }
    
    // MARK: - Share manga
    
    @IBAction func shareManga(sender: UIBarButtonItem) {
        let mangaImage = generateMangaImageForSharing()
        let controller = UIActivityViewController(activityItems: [mangaImage], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func generateMangaImageForSharing() -> UIImage {
        // Hide buttons to avoid inclusion in saved image
//        addToWishListButton.hidden = true
//        addToFavoritesButton.hidden = true
//        animeNewsNetworkButton.hidden = true
        toggleUIDisplayElementsForGeneratingMangaImage()
        
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        // Remember scrollView properties
        let scrollViewContentOffset = scrollView.contentOffset
        let scrollViewFrame = scrollView.frame
        
        scrollView.contentOffset = CGPointZero
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
        scrollView.layer.renderInContext(UIGraphicsGetCurrentContext())        
        let mangaImage = UIGraphicsGetImageFromCurrentImageContext()

        // Restore scrollView properties
        scrollView.contentOffset = scrollViewContentOffset
        scrollView.frame = scrollViewFrame
        
        UIGraphicsEndImageContext()
        
        // Unhide buttons
//        addToWishListButton.hidden = false
//        addToFavoritesButton.hidden = false
//        animeNewsNetworkButton.hidden = false
        toggleUIDisplayElementsForGeneratingMangaImage()
        
        return mangaImage
    }
    
    private func toggleUIDisplayElementsForGeneratingMangaImage() {
        addToWishListButton.hidden = !addToWishListButton.hidden
        addToFavoritesButton.hidden = !addToFavoritesButton.hidden
        dataSourceLabel.hidden = !dataSourceLabel.hidden
        animeNewsNetworkButton.hidden = !animeNewsNetworkButton.hidden
        aniListLabel.hidden = !aniListLabel.hidden
    }
    
    // MARK: - Content
    
    func refreshMangaImage() {
        setMangaImage()
    }
    
    private func setMangaImage() {
        if let imageData = manga.imageData {
            mangaImageView.image = UIImage(data: imageData)!
        } else {
            mangaImageView.image = photoPlaceholderImage
            if !manga.fetchInProgress {
                manga.fetchImageData { fetchComplete in
                    if fetchComplete {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mangaImageView.image = UIImage(data: self.manga.imageData!)
                        }
                    }
                }
            }
        }
    }
    
    private func setTitle() {
        let titleAttributedString = NSMutableAttributedString(string: manga.title)
        titleAttributedString.addAttribute(NSKernAttributeName, value: -1.0, range: NSRange(location: 0, length: titleAttributedString.length))
        titleLabel.attributedText = titleAttributedString
    }
    
    private func setStaff() {
        var allStaffDidAddFirstLine = false
        var allStaffAttributedString = NSMutableAttributedString(string: "")

        var personsConcatenatedByTask = [String:String]()
        
        for staff in manga.staff {
            if personsConcatenatedByTask[staff.task] != nil {
                personsConcatenatedByTask[staff.task]! += ", " + staff.person as String
            } else {
                personsConcatenatedByTask[staff.task] = staff.person
            }
        }
        
        for (task, person) in personsConcatenatedByTask {
            var staffAttributedString = NSMutableAttributedString(string: "")
            if !allStaffDidAddFirstLine {
                allStaffDidAddFirstLine = true
                staffAttributedString.appendAttributedString(NSMutableAttributedString(string: task))
            } else {
                staffAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + task))
            }
            staffAttributedString.addAttributes(attributesForStaffHeading, range: NSRange(location: 0, length: staffAttributedString.length))
            staffAttributedString.appendAttributedString(NSAttributedString(string: " " + person))
            
            allStaffAttributedString.appendAttributedString(staffAttributedString)
        }

        staffLabel.attributedText = allStaffAttributedString
    }
    
    private func setBayesianAverage() {
        if manga.bayesianAverage > 0 {
            bayesianAverageLabel.hidden = false
            
            let average = Double(round(manga.bayesianAverage*10)/10)
            bayesianAverageLabel.text = "\(average)"
        } else {
            bayesianAverageLabel.hidden = true
        }
    }
    
    private func setPlotSummary() {
        if let plotSummary = manga.plotSummary {
            var plotSummaryAttributedString = NSMutableAttributedString(string: "Plot Summary")
            plotSummaryAttributedString.addAttributes(attributesForHeading, range: NSRange(location: 0, length: plotSummaryAttributedString.length))
            let plotSummaryHeaderEndLocation = plotSummaryAttributedString.length
            
            plotSummaryAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + plotSummary))
            plotSummaryAttributedString.addAttributes(attributesForBody, range: NSRange(location: plotSummaryHeaderEndLocation, length: plotSummaryAttributedString.length - plotSummaryHeaderEndLocation))
            
            plotSummaryLabel.attributedText = plotSummaryAttributedString
            
        } else {
            plotSummaryLabel.hidden = true
        }
    }
    
    private func setAlternativeTitle() {
        var allAlternativeTitles = ""
        for alternativeTitle in manga.alternativeTitle {
            if allAlternativeTitles.isEmpty {
                allAlternativeTitles = alternativeTitle.title
            } else {
                allAlternativeTitles += ", " + alternativeTitle.title
            }
        }
        if !allAlternativeTitles.isEmpty {
            var alternativeTitlesAttributedString = NSMutableAttributedString(string: "Alternative Titles")
            alternativeTitlesAttributedString.addAttributes(attributesForHeading, range: NSRange(location: 0, length: alternativeTitlesAttributedString.length))
            let alternativeTitlesHeaderEndLocation = alternativeTitlesAttributedString.length
            
            alternativeTitlesAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + allAlternativeTitles))
            alternativeTitlesAttributedString.addAttributes(attributesForBody, range: NSRange(location: alternativeTitlesHeaderEndLocation, length: alternativeTitlesAttributedString.length - alternativeTitlesHeaderEndLocation))
            alternativeTitleLabel.attributedText = alternativeTitlesAttributedString
        } else {
            alternativeTitleLabel.hidden = true
        }
    }
    
}
