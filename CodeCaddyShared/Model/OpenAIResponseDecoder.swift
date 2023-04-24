// -------------------------------------------------------------------------
//  OpenAIResponseDecoder.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// --------------------------------------------------------------------------

import Foundation

/**
 This `struct` is responsible for decoding JSON responses coming from the OpenAI API.
 */
struct OpenAIResponseDecoder {
    /**
     Decodes a JSON-encoded string and returns an `OpenAIResponse` object.

     - Parameter jsonString: The JSON-encoded string to decode.
     - Returns: An `OpenAIResponse` object if decoding was successful, otherwise `nil`.
     */
    public func decodeJSON(jsonString: String) -> OpenAIResponse? {
        guard let json = jsonString.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let openAIResponse = try decoder.decode(OpenAIResponse.self, from: json)
            return openAIResponse

        } catch {
            print("Error decoding OpenAI API Response -- \(error.localizedDescription)")
            return nil
        }
    }
}

/**
 Represents a response coming from the OpenAI API.
 */
struct OpenAIResponse: Codable {
    var id: String?
    var object: String?
    var created: Int?
    var choices: [Choice]
    var usage: Usage?
}

/**
 Represents a single option of a response coming from the OpenAI API.
 */
struct Choice: Codable {
    var index: Int?
    var message: [String: String]
    var finish_reason: String?
}

/**
 Represents usage statistics for a response coming from the OpenAI API.
 */
struct Usage: Codable {
    var prompt_tokens: Int?
    var completion_tokens: Int?
    var total_tokens: Int?
}
