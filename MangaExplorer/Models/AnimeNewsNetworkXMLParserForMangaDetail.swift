//
//  AnimeNewsNetworkXMLParserForMangaDetail.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/30/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AnimeNewsNetworkXMLParserForMangaDetail: NSObject, NSXMLParserDelegate {
    var mangaProperties = [[String:AnyObject]]()
    var mangaProperty = [String:AnyObject]()
    var elementName = ""
    var attributeDictType = ""
    var gid = ""
    var genres = [String]()
    var alternativeTitles = [String]()
    var alternativeTitle = ""
    var staff = [[String:String]]()
    var task = ""
    var person = ""
    var news = [[String:AnyObject]]()
    var newsDateTime = ""
    var newsHref = ""
    var newsTitle = ""
    
    func parseWithData(data: NSData, completionHandler: (mangaProperties: [[String:AnyObject]]?, errorString: String?) -> Void) {
        // There is a problem with UTF8 encoding from Anime News Network,
        // so we turn data into string and back to data
        let dataAsString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let dataReEncoded = dataAsString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let parser = NSXMLParser(data: dataReEncoded)
        parser.delegate = self
        let success = parser.parse()
        if success == true {
            completionHandler(mangaProperties: mangaProperties, errorString: nil)
        } else {
            completionHandler(mangaProperties: nil, errorString: "Parse failed")
        }
    }
    
    // MARK: - NSXMLParser delegates
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.elementName = elementName
        
        switch elementName {
        case "manga":
            if let id = attributeDict["id"] {
                mangaProperty["id"] = NSNumberFormatter().numberFromString(id)
            }
            if let title = attributeDict["name"] {
                if mangaProperty["title"] != nil {
                    mangaProperty["title"] = mangaProperty["title"] as! String + title
                } else {
                    mangaProperty["title"] = title
                }
            }
        case "ratings":
            if let bayesianAverage = attributeDict["bayesian_score"] {
                mangaProperty["bayesianAverage"] = NSNumberFormatter().numberFromString(bayesianAverage)
            }
        case "info":
            if let attributeDictType = attributeDict["type"] {
                switch attributeDictType {
                case "Picture":
                    if let src = attributeDict["src"] {
                        mangaProperty["imageRemotePath"] = src
                    }
                case "Plot Summary":
                    self.attributeDictType = "Plot Summary"
                case "Genres":
                    self.attributeDictType = "Genres"
                case "Alternative title":
                    self.attributeDictType = "Alternative title"
                default:
                    break
                }
            }
        case "news":
            if let dateTime = attributeDict["datetime"] {
                newsDateTime = dateTime
            }
            if let href = attributeDict["href"] {
                newsHref = href
            }
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        switch elementName {
        case "info":
            switch attributeDictType {
            case "Plot Summary":
                if mangaProperty["plotSummary"] != nil {
                    mangaProperty["plotSummary"] = mangaProperty["plotSummary"] as! String + string
                } else {
                    mangaProperty["plotSummary"] = string
                }
            case "Genres":
                genres.append(string)
            case "Alternative title":
                if alternativeTitle.isEmpty {
                    alternativeTitle = string
                } else {
                    alternativeTitle = alternativeTitle + string
                }
            default:
                break
            }
        case "task":
            if task.isEmpty {
                task = string
            } else {
                task = task + string
            }
        case "person":
            if person.isEmpty {
                person = string
            } else {
                person = person + string
            }
        case "news":
            if newsTitle.isEmpty {
                newsTitle = string
            } else {
                newsTitle = newsTitle + string
            }
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "info" {
            switch attributeDictType {
            case "Alternative title":
                alternativeTitle = alternativeTitle.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                alternativeTitles.append(alternativeTitle)
                alternativeTitle = ""
            default:
                break
            }
        }
        
        if elementName == "staff" {
            staff.append([
                "task": task,
                "person": person
                ])
            task = ""
            person = ""
        }
        
        if elementName == "news" {
            newsTitle = newsTitle.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            news.append([
                "dateTime": newsDateTime,
                "href": newsHref,
                "title": newsTitle
                ])
            newsDateTime = ""
            newsHref = ""
            newsTitle = ""
        }
        
        if elementName == "manga" {
            if let plotSummary = mangaProperty["plotSummary"] as? String {
                mangaProperty["plotSummary"] = plotSummary.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            }
            
            mangaProperty["genres"] = genres
            mangaProperty["alternativeTitles"] = alternativeTitles
            mangaProperty["staff"] = staff
            mangaProperty["news"] = news
            
            mangaProperties.append(mangaProperty)
            
            mangaProperty = [String:AnyObject]()
            genres = [String]()
            alternativeTitles = [String]()
            staff = [[String:String]]()
            news = [[String:AnyObject]]()
        }
        
        self.elementName = ""
        attributeDictType = ""
        gid = ""
    }
    
    // Error detection
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("parseErrorOccurred: \(parseError)")
    }
    
    func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
        NSLog("validationErrorOccurred: \(validationError)")
    }
    
}