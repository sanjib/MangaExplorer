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
    var accessTokenExpiresIn: Int?
    
    private override init() {
        super.init()
    }
    
    private struct Constants {
        static let baseURL = "https://anilist.co/api/"
        
    }
    
    private struct Methods {
        static let authAccessToken = "auth/access_token"
        static let mangaSearch = "manga/search/{query}"
        static let mangaCharacters = "manga/{id}/characters"
        static let characterDetails = "character/{id}"
    }
    
    private func grantClientCredentials(completionHandler: ()->Void) {
        let bodyParams = [
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        let urlString = Constants.baseURL + Methods.authAccessToken
        httpPost(urlString, httpBodyParams: bodyParams) { result, error in
            if error == nil {
                if let accessToken = result["access_token"] as? String {
                    self.accessToken = accessToken
                    if let expires = result["expires"] as? Int {
                        self.accessTokenExpires = expires
                        if let expiresIn = result["expires_in"] as? Int {
                            self.accessTokenExpiresIn = expiresIn
                            
                            println("access token set: \(self.accessToken)")
                            
                            completionHandler()
                        }
                    }
                }
            }
        }
    }
    
    private func isAccessTokenValid() -> Bool {
        if accessToken.isEmpty {
            return false
        } else {
            // TODO: check if token has expired
            
            return true
        }
    }
    
    private func mangaSearch(title: String, completionHandler: (mangas: [[String:AnyObject]]?, errorString: String?) -> Void) {
        let params = [
            "access_token": accessToken
        ]
        let url = Constants.baseURL + urlKeySubstitute(Methods.mangaSearch, kvp: ["query": title]) + urlParamsFromDictionary(params)
        httpGet(url) { result, error in
            if error != nil {
                
            } else {
                completionHandler(mangas: result! as? [[String:AnyObject]], errorString: nil)
            }
        }
    }
    
    private func mangaCharacters(aniListMangaId: Int, completionHandler: (characterIDs: [Int]?, errorString: String?)->Void) {
        let params = [
            "access_token": accessToken
        ]
        let url = Constants.baseURL + urlKeySubstitute(Methods.mangaCharacters, kvp: ["id": "\(aniListMangaId)"]) + urlParamsFromDictionary(params)
        httpGet(url) { result, error in
            if error != nil {
                
            } else {
                var characterIDs = [Int]()
                if let characters = result!["characters"] as? [[String:AnyObject]] {
                    for character in characters {
                        if let characterID = character["id"] as? Int {
                            characterIDs.append(characterID)
                        }
                    }
                    completionHandler(characterIDs: characterIDs, errorString: nil)
                }
            }
        }
    }
    
    private func characterDetails(mangaTitle: String, completionHandler: (characterDetails: [[String:AnyObject]]?, errorString: String?)->Void) {
        let params = [
            "access_token": accessToken
        ]
        mangaSearch(mangaTitle) { mangas, errorString in
            if mangas != nil {
                // get the first match
                
                if let manga = mangas!.first {
                    if let mangaId = manga["id"] as? Int {
                        self.mangaCharacters(mangaId) { characterIDs, errorString in
                            if characterIDs?.count > 0 {
                                var characterIDsToFetch = characterIDs!.count
                                var characterDetails = [[String:AnyObject]]()
                                for characterID in characterIDs! {
                                    let url = Constants.baseURL + self.urlKeySubstitute(Methods.characterDetails, kvp: ["id": "\(characterID)"]) + self.urlParamsFromDictionary(params)
                                    self.httpGet(url) { result, error in
                                        characterIDsToFetch--
                                        if error != nil {
                                            
                                        } else {
                                            characterDetails.append(result as! [String:AnyObject])
                                        }
                                        if characterIDsToFetch == 0 {
                                            completionHandler(characterDetails: characterDetails, errorString: nil)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func getCharacterDetails(mangaTitle: String, completionHandler: (characterDetails: [[String:AnyObject]]?, errorString: String?)->Void) {
        if isAccessTokenValid() {
            characterDetails(mangaTitle, completionHandler: completionHandler)
        } else {
            grantClientCredentials() {
                self.characterDetails(mangaTitle, completionHandler: completionHandler)
            }
        }
    }
    
}