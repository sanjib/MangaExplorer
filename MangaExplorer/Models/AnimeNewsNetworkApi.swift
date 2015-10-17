//
//  AnimeNewsNetworkApi.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/26/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AnimeNewsNetworkApi: CommonRESTApi {
    static let sharedInstance = AnimeNewsNetworkApi()
    
    private override init() {
        super.init()
        super.parseMethod = ParseMethod.xml
    }
    
    private struct Constants {
        static let baseURL = "http://cdn.animenewsnetwork.com/encyclopedia/"        
    }
    
    private struct Methods {
        static let report = "reports.xml"
        static let detail = "api.xml"
    }
    
    func getAllMangas(completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let methodParams: [String:AnyObject] = [
            "id": 155,
            "type": "manga",
            "nlist": "all"
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                let annParserForMangaListWithIdAndTitle = AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle()
                annParserForMangaListWithIdAndTitle.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
    
    func getLatestMangas(skip: Int, completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let methodParams: [String:AnyObject] = [
            "id": 155,
            "type": "manga",
            "nlist": "50",
            "nskip": "\(skip)",
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                let annParserForMangaListWithIdAndTitle = AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle()
                annParserForMangaListWithIdAndTitle.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
    
    // MARK: - Manga details
    
    func getMangaDetails(mangas: [Manga], completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        var mangaIdsInArray = [String]()
        for manga in mangas {
            mangaIdsInArray.append("\(manga.id)")
        }
        getMangaDetails(mangaIdsInArray, completionHandler: completionHandler)
    }
    
    func getMangaDetails(mangaIDs: [Int], completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        var mangaIdsInArray = [String]()
        for id in mangaIDs {
            mangaIdsInArray.append("\(id)")
        }
        getMangaDetails(mangaIdsInArray, completionHandler: completionHandler)
    }
    
    private func getMangaDetails(mangaIdsInArray: [String], completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let mangaIdsInString = mangaIdsInArray.joinWithSeparator("/")
        let methodParams: [String:AnyObject] = [
            "manga": mangaIdsInString
        ]
        let url = Constants.baseURL + Methods.detail + urlParamsFromDictionary(methodParams)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                let annParserForMangaDetail = AnimeNewsNetworkXMLParserForMangaDetail()
                annParserForMangaDetail.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
}