//
//  UserDefaults.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/23/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class UserDefaults {
    
    static let sharedInstance = UserDefaults()
    
    // LatestMangasFetchFrequency
    
    struct LatestMangasFetchFrequency {
        static let Daily = "daily"
        static let Weekly = "weekly"
        static let Monthly = "monthly"
    }
    struct LatestMangasFetchFrequencyDefaults {
        static let Key = "LatestMangasFetchFrequency"
        static let Value = LatestMangasFetchFrequency.Daily
    }
    
    var latestMangasFetchFrequency: String {
        get {
            if let latestMangasFetchFrequency = NSUserDefaults.standardUserDefaults().stringForKey(LatestMangasFetchFrequencyDefaults.Key) {
                return latestMangasFetchFrequency
            } else {
                NSUserDefaults.standardUserDefaults().setObject(LatestMangasFetchFrequencyDefaults.Value, forKey: LatestMangasFetchFrequencyDefaults.Key)
                return LatestMangasFetchFrequencyDefaults.Value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: LatestMangasFetchFrequencyDefaults.Key)
        }
    }
    
    var lastFetchedLatestManga: NSDate? {
        get {
            if let lastFetchedLatestManga = NSUserDefaults.standardUserDefaults().objectForKey("LastFetchedLatestManga") as? NSDate {
                return lastFetchedLatestManga
            } else {
                return nil
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "LastFetchedLatestManga")
        }
    }
    
    func shouldFetchLatestManga() -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        if lastFetchedLatestManga != nil {
            let daysSinceLastUpdate = calendar.components(NSCalendarUnit.Day, fromDate: lastFetchedLatestManga!, toDate: NSDate(), options: [])            
            switch latestMangasFetchFrequency {
            case LatestMangasFetchFrequency.Daily:
                if daysSinceLastUpdate.day >= 1 {
                    return true
                }
            case LatestMangasFetchFrequency.Weekly:
                if daysSinceLastUpdate.day >= 7 {
                    return true
                }
            case LatestMangasFetchFrequency.Monthly:
                if daysSinceLastUpdate.day >= 30 {
                    return true
                }
            default:
                break
            }
            return false
        } else {
            return true
        }
    }
    
    // TopRatedMangasDisplayMax
    
    struct TopRatedMangasDisplayMax {
        // Display in multiples of 5 * 3 (5 columns per row in landscape, 3 columns per row in portrait)
        static let Top300  = 300    // 5 * 3 * 20
        static let Top600  = 600    // 5 * 3 * 40
        static let Top1200 = 1200   // 5 * 3 * 80
        static let Top2400 = 2400   // 5 * 3 * 160
    }
    struct TopRatedMangasDisplayMaxDefaults {
        static let Key = "TopRatedMangasDisplayMax"
        static let Value = TopRatedMangasDisplayMax.Top600
    }
    
    var topRatedMangasDisplayMax: Int {
        get {
            let topRatedMangasDisplayMax = NSUserDefaults.standardUserDefaults().integerForKey(TopRatedMangasDisplayMaxDefaults.Key)
            if topRatedMangasDisplayMax != 0 {
                return topRatedMangasDisplayMax
            } else {
                NSUserDefaults.standardUserDefaults().setObject(TopRatedMangasDisplayMaxDefaults.Value, forKey: TopRatedMangasDisplayMaxDefaults.Key)
                return TopRatedMangasDisplayMaxDefaults.Value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: TopRatedMangasDisplayMaxDefaults.Key)
        }
    }
}