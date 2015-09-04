//
//  AnimeNewsNetworkXMLParserForMangaDetail.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/30/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AnimeNewsNetworkXMLParserForMangaDetail: NSObject, NSXMLParserDelegate {
    // declare data as property (strong) to ensure data doesn't get corrupted while NSXMLParser is crunching the data
    var data: NSData!
    
    var mangaProperties = [[String:AnyObject]]()
    var mangaProperty = [String:AnyObject]()
    var elementName = ""
    var attributeDictType = ""
    
    static let sharedInstance = AnimeNewsNetworkXMLParserForMangaDetail()
    
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
//        println("didStartElement elementName: \(elementName)")
//        println("attributeDict: \(attributeDict)")
        
        self.elementName = elementName
        
        switch elementName {
        case "manga":
            if let id = attributeDict["id"] as? String {
                mangaProperty["id"] = NSNumberFormatter().numberFromString(id) 
            }
            if let title = attributeDict["name"] as? String {
                if mangaProperty["title"] != nil {
                    mangaProperty["title"] = mangaProperty["title"] as! String + title
                } else {
                    mangaProperty["title"] = title
                }
            }
        case "ratings":
            if let bayesianAverage = attributeDict["bayesian_score"] as? String {
                mangaProperty["bayesianAverage"] = NSNumberFormatter().numberFromString(bayesianAverage)
            }
        case "info":
            if let attributeDictType = attributeDict["type"] as? String {
                switch attributeDictType {
                case "Picture":
                    if let src = attributeDict["src"] as? String {
                        mangaProperty["imageRemotePath"] = src
                    }
                case "Plot Summary":
                    self.attributeDictType = "Plot Summary"
//                    println("attributeDictType: \(attributeDictType)")
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
//        println("foundCharacters string: \(string)")

        if let string = string {
            switch elementName {
            case "info":
                switch attributeDictType {
                case "Plot Summary":
//                    println("foundCharacters string: \(string)")
                    if mangaProperty["plotSummary"] != nil {
                        mangaProperty["plotSummary"] = mangaProperty["plotSummary"] as! String + string
                    } else {
                        mangaProperty["plotSummary"] = string
                    }
                default:
                    break
                }                
            default:
                break
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        println("didEndElement elementName: \(elementName)")
        
        if elementName == "manga" {
            mangaProperties.append(mangaProperty)
            mangaProperty = [String:AnyObject]()
        }
        
        self.elementName = ""
        attributeDictType = ""
    }
    
    // Error detection
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        println("parseErrorOccurred: \(parseError)")
    }
    
    func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
        println("validationErrorOccurred: \(validationError)")
    }
    
}