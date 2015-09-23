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