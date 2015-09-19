//
//  MangaListViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/19/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class MangaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var selectedManga: Manga?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core data
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }

    // MARK: - TableView delegates & data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResults.count
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MangaSearchResultCell", forIndexPath: indexPath) as! MangaTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if let manga = searchResults.count > indexPath.row ? searchResults[indexPath.row] : nil {
//            selectedManga = manga
//            performSegueWithIdentifier("MangaDetailsSegue", sender: self)
//        }
    }
    
    // MARK: - Configure cell
    
    func configureCell(cell: MangaTableViewCell, atIndexPath indexPath: NSIndexPath) {
        /*
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
        */
    }
    
    private func safeReloadMangaRowAtIndexPath(indexPath: NSIndexPath, manga: Manga) {
//        if let mangaInSearchResults = searchResults.count > indexPath.row ? searchResults[indexPath.row] : nil {
//            if mangaInSearchResults.id == manga.id {
//                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//            }
//        }
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
