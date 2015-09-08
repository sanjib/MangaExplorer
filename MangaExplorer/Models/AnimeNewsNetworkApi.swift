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
    
    func getAllMangasXMLData(completionHandler: (xmlData: NSData?, errorString: String?) -> Void) {
        let methodParams: [String:AnyObject] = [
            "id": 155,
            "type": "manga",
            "nlist": "all"
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        println(url)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(xmlData: nil, errorString: error?.localizedDescription)
            } else {
                completionHandler(xmlData: xmlData as? NSData, errorString: nil)
            }
        }
    }
    
    func getAllMangas(completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let methodParams: [String:AnyObject] = [
            "id": 155,
            "type": "manga",
            "nlist": "all"
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        println(url)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle.sharedInstance.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
    
    func getLatestMangas(completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {

        let methodParams: [String:AnyObject] = [
            "id": 155,
            "type": "manga",
            "nlist": "50"
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        println(url)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle.sharedInstance.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
    
    func getTopRatedMangasXMLData(completionHandler: (xmlData: NSData?, errorString: String?) -> Void) {
        let methodParams: [String:AnyObject] = [
            "id": 173,
            "nlist": "all"
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        println(url)
        let nsurl = NSURL(string: url)
        
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(xmlData: nil, errorString: error?.localizedDescription)
            } else {
                completionHandler(xmlData: xmlData as? NSData, errorString: nil)
            }
        }
    }
    
    func getTopRatedMangas(completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let methodParams: [String:AnyObject] = [
            "id": 173,
            "nlist": "all"
        ]
        let url = Constants.baseURL + Methods.report + urlParamsFromDictionary(methodParams)
        println(url)
        let nsurl = NSURL(string: url)
        
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                AnimeNewsNetworkXMLParserForMangaListWithRating.sharedInstance.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
    
    func getMangaDetails(mangas: [Manga], completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        var mangaIdsInArray = [String]()
        for manga: Manga in mangas {
            mangaIdsInArray.append("\(manga.id)")
        }
        
        let mangaIdsInString = "/".join(mangaIdsInArray)
        let methodParams: [String:AnyObject] = [
            "manga": mangaIdsInString
        ]
        let url = Constants.baseURL + Methods.detail + urlParamsFromDictionary(methodParams)
        println(url)
        httpGet(url) { xmlData, error in
            if error != nil {
                completionHandler(mangaProperties: nil, errorString: error?.localizedDescription)
            } else {
                AnimeNewsNetworkXMLParserForMangaDetail.sharedInstance.parseWithData(xmlData as! NSData, completionHandler: completionHandler)
            }
        }
    }
}