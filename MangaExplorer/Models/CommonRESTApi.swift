//
//  CommonRESTApi.swift
//  MangaReaderAlpha
//
//  Created by Sanjib Ahmad on 8/26/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

/*
 * The CommonRESTApi provides generalized networking code for web services.
 * It is meant to be sub-classed by vendor-specific custom client classes.
 *
 */

import Foundation

class CommonRESTApi {
    private let session = NSURLSession.sharedSession()
    
    // Can override via subclass
    var additionalHTTPHeaderFields: [String:String]? = nil
    var additionalMethodParams: [String:AnyObject]? = nil
    var parseMethod = ParseMethod.json
    
    private struct ErrorMessage {
        static let Domain = NSBundle.mainBundle().bundleIdentifier!
        static let NoInternet = "You appear to be offline, please connect to the Internet to use MangaReaderAlpha."
        static let InvalidURL = "Invalid URL"
        static let EmptyURL = "Empty URL"
    }
    
    enum ParseMethod {
        case json, xml
    }
    
    func httpGet(urlString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        if Reachability.isConnectedToNetwork() == false {
            completionHandler(result: nil, error: NSError(domain: ErrorMessage.Domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.NoInternet]))
            return
        }
        
        if urlString != "" {
            if let url = NSURL(string: urlString) {
                let request = NSMutableURLRequest(URL: url)
                if let additionalHTTPHeaderFields = additionalHTTPHeaderFields {
                    for (httpHeaderField, value) in additionalHTTPHeaderFields {
                        request.addValue(value, forHTTPHeaderField: httpHeaderField)
                    }
                }
                
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil {
                        completionHandler(result: nil, error: error)
                        return
                    }
                    if self.parseMethod == .json {
                        self.parseJSONData(data!, completionHandler: completionHandler)
                    } else {
                        completionHandler(result: data, error: nil)
                    }                    
                }
                task.resume()
            } else {
                completionHandler(result: nil, error: NSError(domain: ErrorMessage.Domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.InvalidURL]))
            }
        } else {
            completionHandler(result: nil, error: NSError(domain: ErrorMessage.Domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.EmptyURL]))
        }
    }
    
    func httpPost(urlString: String, httpBodyParams: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        if Reachability.isConnectedToNetwork() == false {
            completionHandler(result: nil, error: NSError(domain: ErrorMessage.Domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.NoInternet]))
            return
        }
        
        if urlString != "" {
            if let url = NSURL(string: urlString) {
                let request = NSMutableURLRequest(URL: url)
                if let additionalHTTPHeaderFields = additionalHTTPHeaderFields {
                    for (httpHeaderField, value) in additionalHTTPHeaderFields {
                        request.addValue(value, forHTTPHeaderField: httpHeaderField)
                    }
                }
                request.HTTPMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(httpBodyParams, options: [])
                
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil {
                        completionHandler(result: nil, error: error)
                        return
                    }
                    if self.parseMethod == .json {
                        self.parseJSONData(data!, completionHandler: completionHandler)
                    } else {
                        completionHandler(result: data, error: nil)
                    }
                }
                task.resume()
            } else {
                completionHandler(result: nil, error: NSError(domain: ErrorMessage.Domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.InvalidURL]))
            }
        } else {
            completionHandler(result: nil, error: NSError(domain: ErrorMessage.Domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.EmptyURL]))
        }
    }
    
    // MARK: - Helpers for subclass
    
    func urlKeySubstitute(method: String, kvp: [String:String]) -> String {
        var method = method
        for (key, value) in kvp {
            if method.rangeOfString("{\(key)}") != nil {
                method = method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
            }
        }
        return method
    }
    
    func urlParamsFromDictionary(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        var parameters = parameters
        if let additionalMethodParams = additionalMethodParams {
            for (key, value) in additionalMethodParams {
                parameters[key] = value
            }
        }
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: - Helpers for JSON parsing
    
    private func parseJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
}