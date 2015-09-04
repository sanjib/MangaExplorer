//
//  AnimeNewsNetworkXMLParserForMangaListWithRating.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/26/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AnimeNewsNetworkXMLParserForMangaListWithRating: NSObject, NSXMLParserDelegate {
    // declare data as property (strong) to ensure data doesn't get corrupted while NSXMLParser is crunching the data
    var data: NSData!
    
    var mangaProperties = [[String:AnyObject]]()
    var mangaProperty = [String:AnyObject]()
    var elementName = ""
    
    static let sharedInstance = AnimeNewsNetworkXMLParserForMangaListWithRating()
    
    func parseWithData(data: NSData, completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        // There is a problem with UTF8 encoding from Anime News Network,
        // so we turn data into string and back to data
        let tempString = NSString(data: data, encoding: NSUTF8StringEncoding)
        self.data = tempString?.dataUsingEncoding(NSUTF8StringEncoding)
        
        let parser = NSXMLParser(data: self.data)
        parser.delegate = self
        let success = parser.parse()
        if success == true {
            println("parse successful, call completionHandler")
            completionHandler(mangaProperties: mangaProperties, errorString: nil)
        } else {
            println("parse failed, call completionHandler")
            completionHandler(mangaProperties: nil, errorString: "Parse failed")
        }
    }
    
    // MARK: - NSXMLParser delegates
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
//        println(elementName)
        self.elementName = elementName
        if let id = attributeDict["id"] as? String {
//            mangaProperty["id"] = id
            mangaProperty["id"] = NSNumberFormatter().numberFromString(id)
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
//        println(string)
        if let string = string {
            switch elementName {
            case "manga":
                let mangaTitle = string.stringByReplacingOccurrencesOfString(" (manga)", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                if mangaProperty["title"] != nil {
                    mangaProperty["title"] = mangaProperty["title"] as! String + mangaTitle
                } else {
                    mangaProperty["title"] = mangaTitle
                }                
            case "bayesian_average":
//                mangaProperty["bayesianAverage"] = string
                mangaProperty["bayesianAverage"] = NSNumberFormatter().numberFromString(string)
            default:
                return
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        println(elementName)
        if elementName == "item" {
            mangaProperties.append(mangaProperty)
            mangaProperty = [String:AnyObject]()
        }
    }
    
    // Error detection
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        println("parseErrorOccurred: \(parseError)")
    }
    
    func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
        println("validationErrorOccurred: \(validationError)")
    }
    
}