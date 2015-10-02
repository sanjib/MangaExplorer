//
//  AnimeNewsNetworkBatchUpdater.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/25/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class AnimeNewsNetworkBatchUpdater: NSObject {
    static let sharedInstance = AnimeNewsNetworkBatchUpdater()
    
    let maxBatchSizeForFetchingMangaDetails = 50 // set by Anime News Network
    
    var allMangaIDs = [Int]()
    
    override private init() {
        super.init()
        allMangaIDs = fetchAllMangaIDs()
    }
    
    func updateTopRatedMangas() {
        
    }
    
    func updateWithLatestMangas() {
        println("updateWithLatestMangas \(allMangaIDs.count)")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        getLatestMangas(0, latestMangaIDs: [Int]()) { mangaIDs in
            if mangaIDs != nil {
                self.getMangaDetails(mangaIDs!) { mangaProperties, errorString in
                    if mangaProperties != nil {
                        for mangaProperty in mangaProperties! {
                            autoreleasepool {
                                let id = mangaProperty["id"] as? Int
                                let mangaTitle = mangaProperty["title"] as? String
                                let imageRemotePath = mangaProperty["imageRemotePath"] as? String
                                let bayesianAverage = mangaProperty["bayesianAverage"] as? Double
                                let plotSummary = mangaProperty["plotSummary"] as? String
                                let news = mangaProperty["news"] as? [[String:AnyObject]]
                                let staff = mangaProperty["staff"] as? [[String:String]]
                                let alternativeTitles = mangaProperty["alternativeTitles"] as? [String]
                                let genres = mangaProperty["genres"] as? [String]
                                
                                if id != nil && mangaTitle != nil {
                                    let manga = Manga(id: id!, title: mangaTitle!, context: sharedContext)
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
                                                    let staff = Staff(task: task!, person: person!, context: sharedContext)
                                                    staff.manga = manga
                                                }
                                            }
                                        }
                                    }
                                    if alternativeTitles != nil {
                                        for anAlternativeTitle: String in alternativeTitles! {
                                            let alternativeTitle = AlternativeTitle(title: anAlternativeTitle, context: sharedContext)
                                            alternativeTitle.manga = manga
                                        }
                                    }
                                    if genres != nil {
                                        for aGenre: String in genres! {
                                            let genre = Genre(name: aGenre, context: sharedContext)
                                            genre.manga = manga
                                        }
                                    }
                                }
                            }
                        }
                        CoreDataStackManager.sharedInstance.saveContext()
                        UserDefaults.sharedInstance.lastFetchedLatestManga = NSDate()
                    }
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    private func getMangaDetails(mangaIDs: [Int], completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?)->Void) {
        var allMangaProperties = [[String:AnyObject]]()
        var mangaIDsInCurrentBatch = [Int]()
        var fetchCount = 0
        
        for id in mangaIDs {
            mangaIDsInCurrentBatch.append(id)
            if mangaIDsInCurrentBatch.count >= maxBatchSizeForFetchingMangaDetails {
                fetchCount++
                AnimeNewsNetworkApi.sharedInstance.getMangaDetails(mangaIDsInCurrentBatch) { mangaProperties, errorString in
                    fetchCount--
                    if mangaProperties != nil {
                        for mangaProperty in mangaProperties! {
                            var aMangaProperty = mangaProperty
                            if aMangaProperty["news"] != nil {
                                aMangaProperty["news"] = nil
                            }
                            var inGenreErotica = false
                            if let genres = aMangaProperty["genres"] as? [String] {
                                for aGenre in genres {
                                    if aGenre == "erotica" {
                                        inGenreErotica = true
                                        continue
                                    }
                                }
                            }
                            if inGenreErotica == true {
                                continue
                            }
                            allMangaProperties.append(aMangaProperty)
                        }
                        if fetchCount == 0 {
                            completionHandler(mangaProperties: allMangaProperties, errorString: nil)
                        }
                    }
                }
                mangaIDsInCurrentBatch = [Int]()
                usleep(200000) // 1 request per second per IP address, we set to 2 seconds to be on the safe side
            }
        }
        
        if mangaIDsInCurrentBatch.count >= 0 {
            fetchCount++
            AnimeNewsNetworkApi.sharedInstance.getMangaDetails(mangaIDsInCurrentBatch) { mangaProperties, errorString in
                fetchCount--
                if mangaProperties != nil {
                    for mangaProperty in mangaProperties! {
                        var aMangaProperty = mangaProperty
                        if aMangaProperty["news"] != nil {
                            aMangaProperty["news"] = nil
                        }
                        var inGenreErotica = false
                        if let genres = aMangaProperty["genres"] as? [String] {
                            for aGenre in genres {
                                if aGenre == "erotica" {
                                    inGenreErotica = true
                                    continue
                                }
                            }
                        }
                        if inGenreErotica == true {
                            continue
                        }
                        allMangaProperties.append(aMangaProperty)
                    }
                    if fetchCount == 0 {
                        completionHandler(mangaProperties: allMangaProperties, errorString: nil)
                    }
                }
            }
        }
        
    }
    
    private func getLatestMangas(var skip: Int, var latestMangaIDs: [Int], completionHandler: (mangaIDs: [Int]?)->Void) {
        AnimeNewsNetworkApi.sharedInstance.getLatestMangas(skip) { mangaProperties, errorString in
            if mangaProperties != nil {
                var mangaIDFound = false
                for mangaProperty in mangaProperties! {
                    if let id = mangaProperty["id"] as? Int {
                        if contains(self.allMangaIDs, id) {
                            completionHandler(mangaIDs: latestMangaIDs)
                            mangaIDFound = true
                            break
                        } else {
                            latestMangaIDs.append(id)
                        }
                    }
                }
                if !mangaIDFound {
                    self.getLatestMangas(skip + 50, latestMangaIDs: latestMangaIDs, completionHandler: completionHandler)
                }
            }
        }
    }
    
    
}

// MARK: - CoreData

var sharedContext: NSManagedObjectContext {
    return CoreDataStackManager.sharedInstance.managedObjectContext!
}

func fetchAllMangaIDs() -> [Int] {
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = NSEntityDescription.entityForName("Manga", inManagedObjectContext: sharedContext)
    fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
    fetchRequest.propertiesToFetch = ["id"]

    var error: NSError? = nil
    var results =  sharedContext.executeFetchRequest(fetchRequest, error: &error)
    
    if let error = error {
        return [Int]()
    }
    
    var allMangaIDs = [Int]()
    for result in results as! [NSDictionary] {
        if let id = result["id"] as? Int {
            allMangaIDs.append(id)
        }
    }
    return allMangaIDs
}