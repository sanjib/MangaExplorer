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
}