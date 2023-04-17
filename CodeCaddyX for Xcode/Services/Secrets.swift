//
//  Secrets.swift
//  CodeCaddyX for Xcode
//
//  Created by Chris Golding on 4/17/23.
//

import Foundation

struct Secrets {
    static let chatGPTApiKey: String = {
        guard let apiKey = secrets.value(forKey: "CHATGPT_API_KEY") as? String else {
            fatalError("CHATGPT_API_KEY was not found in Secrets.plist")
        }
        return apiKey
    }()
    
    static private let secrets: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            fatalError("Secrets.plist not found.  Copy Secrets_Example.plist to Secrets.plist and provide values for the containing items.")
        }
        
        guard let secrets = NSDictionary(contentsOfFile: path) else {
            fatalError("Secrets.plist is not in the proper format.")
        }
        
        return secrets
    }()
}
