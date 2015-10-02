//
//  AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/27/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle: NSObject, NSXMLParserDelegate {
    var mangaProperties = [[String:AnyObject]]()
    var mangaProperty = [String:AnyObject]()
    var elementName = ""
    
//    static let sharedInstance = AnimeNewsNetworkXMLParserForMangaListWithIdAndTitle()
    
    func parseWithData(data: NSData, completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        // There is a problem with UTF8 encoding from Anime News Network,
        // so we turn data into string and back to data
        let dataAsString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let dataReEncoded = dataAsString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let parser = NSXMLParser(data: dataReEncoded)
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
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
//        println(string)
        if let string = string {
            switch elementName {
            case "id":
                mangaProperty["id"] = NSNumberFormatter().numberFromString(string)
            case "name":
                if mangaProperty["title"] != nil {
                    mangaProperty["title"] = mangaProperty["title"] as! String + string
                } else {
                    mangaProperty["title"] = string
                }
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