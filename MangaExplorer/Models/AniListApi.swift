//
//  AniListApi.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 10/2/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AniListApi: CommonRESTApi {
    static let sharedInstance = AniListApi()
    
    let clientId = "sanjib-lsb7z"
    let clientSecret = "ImTYNrer7uLHUO6CFGV"
    
    var accessToken = ""
    var accessTokenExpires: Int?
    
    private override init() {
        super.init()
    }
    
    private struct Constants {
        static let baseURL = "https://anilist.co/api/"
        
    }
    
    private struct Methods {
        static let authAccessToken = "auth/access_token"
        static let mangaSearch = "manga/search/{query}"
        static let allCharactersSmallModel = "manga/{id}/characters"
        static let aCharacterFullModel = "character/{id}"
    }
    
    private func grantClientCredentials(completionHandler: ()->Void) {
        let bodyParams = [
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        let urlString = Constants.baseURL + Methods.authAccessToken
        httpPost(urlString, httpBodyParams: bodyParams) { result, error in
            println(result)
            if error == nil {
                if let accessToken = result["access_token"] as? String {
                    self.accessToken = accessToken
                    if let expires = result["expires"] as? Int {
                        self.accessTokenExpires = expires
                        
                        println("access token set: \(self.accessToken)")
                        println("access token set: \(self.accessTokenExpires)")
                        
                        completionHandler()
                    }
                }
            }
        }
    }
    
    private func isAccessTokenValid() -> Bool {
        if accessToken.isEmpty {
            return false
        } else {
            if Int(NSDate().timeIntervalSince1970) >= accessTokenExpires {
                return false
            } else {
                return true
            }
        }
    }
    
    private func mangaSearch(title: String, completionHandler: (mangas: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let params = [
            "access_token": accessToken
        ]
        if let title = title.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            let url = Constants.baseURL + urlKeySubstitute(Methods.mangaSearch, kvp: ["query": title]) + urlParamsFromDictionary(params)
            httpGet(url) { result, error in
                println("mangaSearch result: \(result)")
                println("mangaSearch error: \(error)")
                if error != nil {
                    completionHandler(mangas: nil, errorString: error?.localizedDescription)
                } else {
                    completionHandler(mangas: result! as? [[String:AnyObject]], errorString: nil)
                }
            }
        } else {
            completionHandler(mangas: nil, errorString: "Could not encode query string")
        }

    }
    
    private func allCharactersSmallModel(aniListMangaId: Int, completionHandler: (allCharactersSmallModel: [[String:AnyObject]]?, errorString: String?)->Void) {
        let params = [
            "access_token": accessToken
        ]
        let url = Constants.baseURL + urlKeySubstitute(Methods.allCharactersSmallModel, kvp: ["id": "\(aniListMangaId)"]) + urlParamsFromDictionary(params)
        httpGet(url) { result, error in
            if error != nil {
                completionHandler(allCharactersSmallModel: nil, errorString: error?.localizedDescription)
            } else {
                if let allCharactersSmallModel = result!["characters"] as? [[String:AnyObject]] {
                    completionHandler(allCharactersSmallModel: allCharactersSmallModel, errorString: nil)
                }
            }
        }
    }
    
    private func getAllCharactersFullModelWithValidAccessToken(mangaTitle: String, completionHandler: (allCharactersFullModel: [[String:AnyObject]]?, errorString: String?)->Void) {
        let params = [
            "access_token": accessToken
        ]
        mangaSearch(mangaTitle) { mangas, errorString in
            if mangas != nil {
                // get the first match
                
                if let manga = mangas!.first {
                    if let mangaId = manga["id"] as? Int {
                        self.allCharactersSmallModel(mangaId) { allCharactersSmallModel, errorString in
                            if allCharactersSmallModel?.count > 0 {
                                var characterIDsToFetch = allCharactersSmallModel!.count
                                var allCharactersFullModel = [[String:AnyObject]]()
                                
                                for aCharacterSmallModel in allCharactersSmallModel! {
                                    if let characterID = aCharacterSmallModel["id"] as? Int {
                                        let url = Constants.baseURL + self.urlKeySubstitute(Methods.aCharacterFullModel, kvp: ["id": "\(characterID)"]) + self.urlParamsFromDictionary(params)
                                        self.httpGet(url) { result, error in
                                            characterIDsToFetch--
                                            if error != nil {
                                                
                                            } else {
                                                allCharactersFullModel.append(result as! [String:AnyObject])
                                            }
                                            if characterIDsToFetch == 0 {
                                                completionHandler(allCharactersFullModel: allCharactersFullModel, errorString: nil)
                                            }
                                        }
                                    }
                                }
                            } else {
                                completionHandler(allCharactersFullModel: nil, errorString: "Could not get manga characters")
                            }
                        }
                    } else {
                        completionHandler(allCharactersFullModel: nil, errorString: "Could not get manga characters")
                    }
                } else {
                    completionHandler(allCharactersFullModel: nil, errorString: "Could not get manga characters")
                }
            } else {
                completionHandler(allCharactersFullModel: nil, errorString: "Could not get manga characters")
            }
        }
    }
    
    private func getAllCharactersSmallModelWithValidAccessToken(mangaTitle: String, completionHandler: (allCharactersSmallModel: [[String:AnyObject]]?, errorString: String?)->Void) {
        let params = [
            "access_token": accessToken
        ]
        mangaSearch(mangaTitle) { mangas, errorString in
//            println("mangas from search query: \(mangas)")
            
            if mangas != nil {
                // get the first match
                
                if let manga = mangas!.first {
                    if let mangaId = manga["id"] as? Int {
                        self.allCharactersSmallModel(mangaId) { allCharactersSmallModel, errorString in
                            if allCharactersSmallModel?.count > 0 {
                                completionHandler(allCharactersSmallModel: allCharactersSmallModel, errorString: nil)
                            } else {
                                completionHandler(allCharactersSmallModel: nil, errorString: "Could not get manga characters")
                            }
                        }
                    } else {
                        completionHandler(allCharactersSmallModel: nil, errorString: "Could not get manga characters")
                    }
                } else {
                    completionHandler(allCharactersSmallModel: nil, errorString: "Could not get manga characters")
                }
            } else {
                completionHandler(allCharactersSmallModel: nil, errorString: "Could not get manga characters")
            }
        }
    }
    
    func getAllCharactersFullModel(mangaTitle: String, completionHandler: (allCharactersFullModel: [[String:AnyObject]]?, errorString: String?)->Void) {
        if isAccessTokenValid() {
            getAllCharactersFullModelWithValidAccessToken(mangaTitle, completionHandler: completionHandler)
        } else {
            grantClientCredentials() {
                self.getAllCharactersFullModelWithValidAccessToken(mangaTitle, completionHandler: completionHandler)
            }
        }
    }
    
    func getAllCharactersSmallModel(mangaTitle: String, completionHandler: (allCharactersSmallModel: [[String:AnyObject]]?, errorString: String?)->Void) {
        if isAccessTokenValid() {
            getAllCharactersSmallModelWithValidAccessToken(mangaTitle, completionHandler: completionHandler)
        } else {
            grantClientCredentials() {
                self.getAllCharactersSmallModelWithValidAccessToken(mangaTitle, completionHandler: completionHandler)
            }
        }
    }
    
}