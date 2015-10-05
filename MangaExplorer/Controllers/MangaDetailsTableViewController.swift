//
//  MangaDetailsTableViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 10/3/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class MangaDetailsTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var mangaImageView: UIImageView!
    @IBOutlet weak var mangaBackgroundImageView: UIImageView!
    @IBOutlet weak var mangaTitleLabel: UILabel!
    @IBOutlet weak var mangaRankingLabel: UILabel!
    @IBOutlet weak var mangaStaffLabel: UILabel!
    @IBOutlet weak var addToWishListButton: AddToButton!
    @IBOutlet weak var addToFavoritesButton: AddToButton!
    @IBOutlet weak var plotSummaryLabel: UILabel!
    @IBOutlet weak var alternativeTitleLabel: UILabel!
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    
    var mangaId: NSNumber!
    private var manga: Manga!
    private var cache = NSCache()
    let backgroundQueue = dispatch_queue_create("MangaExplorerDetails", DISPATCH_QUEUE_SERIAL)
    
    private let photoPlaceholderImage = UIImage(named: "mangaPlaceholder")
    
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
    
    // Cell layout properties
    let cellsPerRowInPortraitMode: CGFloat = 2
    let cellsPerRowInLandscpaeMode: CGFloat = 3
    let minimumSpacingPerCell: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        
        mangaRankingLabel.layer.cornerRadius = 3.0
        mangaRankingLabel.clipsToBounds = true
        
        tableView.estimatedRowHeight = 100
        
        let blurredEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurredEffectView = UIVisualEffectView(effect: blurredEffect)
        blurredEffectView.frame = mangaBackgroundImageView.bounds
        blurredEffectView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        mangaBackgroundImageView.addSubview(blurredEffectView)

//        charactersNotAvailableLabel.hidden = true                
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMangaImage", name: "refreshMangaImageNotification", object: nil)
        
        manga = fetchManga()

        // Content
        setMangaCharacterImagesInCache()
        setMangaImage()
        setMangaTitle()
        setMangaStaff()
        setMangaRanking()
        setPlotSummary()
        setAlternativeTitle()
        setMangaCharacters()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // Set button titles in viewWillAppear because mangas may 
        // be added/removed from wish/favorite list in other views
        setTitleForWishListButton()
        setTitleForFavoritesButton()
        
        tableReloadForViewController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        tableReloadForViewController()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(false)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Reset table layout
    
    private func tableReloadForViewController() {
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    // MARK: - NSCache
    
    private func setMangaCharacterImagesInCache() {
        dispatch_async(backgroundQueue) {
            if self.manga.character.count > 0 {
                for character in self.manga.character {
                    if let imageData = character.imageData {
                        if let image = UIImage(data: imageData) {
                            self.cache.setObject(image, forKey: character.imageName!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.charactersCollectionView.reloadData()
                }
            }
        }
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
    
    // MARK: - Buttons
    
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
    
    @IBAction func linkToAnimeNewsNetwork(sender: UIButton) {
        let urlString =  "http://www.animenewsnetwork.com/encyclopedia/manga.php?id=\(manga.id)"
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func linkToAniList(sender: UIButton) {
        let urlString =  "https://anilist.co/browse/manga"
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
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
        toggleUIDisplayElementsForGeneratingMangaImage()
        
        UIGraphicsBeginImageContext(tableView.contentSize)
        
        // Remember scrollView properties
        let tableViewContentOffset = tableView.contentOffset
        let tableViewFrame = tableView.frame
        
        tableView.contentOffset = CGPointZero
        tableView.frame = CGRectMake(0, 0, tableView.contentSize.width, tableView.contentSize.height)
        tableView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let mangaImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Restore scrollView properties
        tableView.contentOffset = tableViewContentOffset
        tableView.frame = tableViewFrame
        
        UIGraphicsEndImageContext()
        
        // Unhide buttons
        toggleUIDisplayElementsForGeneratingMangaImage()
        
        return mangaImage
    }
    
    private func toggleUIDisplayElementsForGeneratingMangaImage() {
        addToWishListButton.hidden = !addToWishListButton.hidden
        addToFavoritesButton.hidden = !addToFavoritesButton.hidden
    }
    
    // MARK: - Content
    
    func refreshMangaImage() {
        setMangaImage()
    }
    
    private func setMangaImage() {
        if let imageData = manga.imageData {
            let mangaImage = UIImage(data: imageData)!
            mangaImageView.image = mangaImage
            mangaBackgroundImageView.image = mangaImage
        } else {
            mangaImageView.image = photoPlaceholderImage
            if !manga.fetchInProgress {
                manga.fetchImageData { fetchComplete in
                    if fetchComplete {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let imageData = self.manga.imageData {
                                if let mangaImage = UIImage(data: imageData) {
                                    self.mangaImageView.image = mangaImage
                                    self.mangaBackgroundImageView.image = mangaImage
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setMangaTitle() {
        mangaTitleLabel.text = manga.title
    }

    private func setMangaStaff() {
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
        
        mangaStaffLabel.attributedText = allStaffAttributedString
    }
    
    private func setMangaRanking() {
        if manga.bayesianAverage > 0 {
            mangaRankingLabel.hidden = false
            
            let average = Double(round(manga.bayesianAverage*10)/10)
            mangaRankingLabel.text = "\(average)"
        } else {
            mangaRankingLabel.hidden = true
        }
    }
    
    private func setPlotSummary() {
        if let plotSummary = manga.plotSummary {
            plotSummaryLabel.text = plotSummary

        } else {
            plotSummaryLabel.text = "Not available"
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
        if allAlternativeTitles.isEmpty {
            alternativeTitleLabel.text = "Not available"
        } else {
           alternativeTitleLabel.text = allAlternativeTitles
        }
    }
    
    private func setMangaCharacters() {
        if manga.character.count == 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            AniListApi.sharedInstance.getAllCharactersSmallModel(manga.title) { allCharactersSmallModel, errorString in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if allCharactersSmallModel != nil {
                    for aCharacter in allCharactersSmallModel! {
                        var firstName = ""
                        if let aFirstName = aCharacter["name_first"] as? String {
                            firstName = aFirstName
                        }
                        var lastName = ""
                        if let aLastName = aCharacter["name_last"] as? String {
                            lastName = aLastName
                        }
                        let character = Character(firstName: firstName, lastName: lastName, context: self.sharedContext)
                        if let imageRemotePath = aCharacter["image_url_med"] as? String {
                            character.imageRemotePath = imageRemotePath
                        }
                        character.manga = self.manga                        
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        CoreDataStackManager.sharedInstance.saveContext()
                        self.charactersCollectionView.reloadData()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source and delegates
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 300 // height of manga image row
        case 3:
            let height = charactersCollectionView.collectionViewLayout.collectionViewContentSize().height
            return height + 24 // add padding for top and bottom margins
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel.textColor = UIColor.whiteColor()
            view.contentView.backgroundColor = UIColor.blackColor()
        }
    }
    
    // MARK: - Collection view delegates and data source
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CharacterCell", forIndexPath: indexPath) as! CharacterCollectionViewCell
        let character = manga.character[indexPath.row]
        
        cell.characterNameLabel.text = "\(character.firstName) \(character.lastName)"
        
        // if imageName: check in cache, else check if already downloaded, else fetch
        if let imageName = character.imageName {
            if let image = cache.objectForKey(imageName) as? UIImage {
                cell.characterImageView.image = image
                cell.activityIndicator.stopAnimating()
            } else {
                if let imageData = character.imageData {
                    if let image = UIImage(data: imageData) {
                        cache.setObject(image, forKey: imageName)
                        cell.characterImageView.image = image
                    } else {
                        cell.characterImageView.image = photoPlaceholderImage
                    }
                    cell.activityIndicator.stopAnimating()
                } else {
                    cell.characterImageView.image = photoPlaceholderImage
                    cell.activityIndicator.startAnimating()
                    if !character.fetchInProgress {
                        character.fetchImageData { fetchComplete in
                            if fetchComplete {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.charactersCollectionView.reloadItemsAtIndexPaths([indexPath])
                                }
                            }
                        }
                    }
                }
            }
        } else {
            cell.characterImageView.image = photoPlaceholderImage
            cell.activityIndicator.stopAnimating()
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manga.character.count
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = minimumSpacingPerCell
        layout.minimumInteritemSpacing = minimumSpacingPerCell
        
        var cellWidth: CGFloat!
        
        if UIApplication.sharedApplication().statusBarOrientation.isLandscape == true {
            let totalSpacingBetweenCells = (minimumSpacingPerCell * cellsPerRowInLandscpaeMode) - minimumSpacingPerCell
            let availableWidthForCells = charactersCollectionView.frame.size.width - totalSpacingBetweenCells
            cellWidth = availableWidthForCells / cellsPerRowInLandscpaeMode
        } else {
            let totalSpacingBetweenCells = (minimumSpacingPerCell * cellsPerRowInPortraitMode) - minimumSpacingPerCell
            let availableWidthForCells = charactersCollectionView.frame.size.width - totalSpacingBetweenCells
            cellWidth = availableWidthForCells / cellsPerRowInPortraitMode
        }
        
        layout.itemSize = CGSize(width: cellWidth, height: 60)
        charactersCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        charactersCollectionView.collectionViewLayout.invalidateLayout()
        charactersCollectionView.performBatchUpdates(nil, completion: nil)
    }

}
