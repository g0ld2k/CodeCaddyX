// -------------------------------------------------------------------------
//  OpenAIConnector.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// --------------------------------------------------------------------------

import Combine
import Foundation

// Adapted from: https://medium.com/codex/how-to-use-chatgpt-with-swift-f4ee213d6ba9

public enum OpenAIConnectorError: Error {
    case apiKeyNotFound
}

public class OpenAIConnector: ObservableObject {
    /// This URL might change in the future, so if you get an error, make sure to check the OpenAI API Reference.
    let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")

    /// This is what stores your messages. You can see how to use it in a SwiftUI view here:
    @Published public var messageLog: [[String: String]] = [
        /// Modify this to change the personality of the assistant.
        ["role": "system", "content": "You're a friendly, helpful assistant"],
    ]

    public init() {}

    public func sendToAssistant() async throws {
        guard let apiKey = try? await KeychainService.shared.load(secretKey: KeychainKeys.openAIAPIKey) else {
            print("API Key Not Found")
            return
        }

        var request = URLRequest(url: openAIURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let httpBody: [String: Any] = [
            /// In the future, you can use a different chat model here.
            "model": "gpt-3.5-turbo",
            "messages": messageLog,
        ]

        var httpBodyJson: Data?

        do {
            httpBodyJson = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        } catch {
            print("Unable to convert to JSON \(error)")
            logMessage("error", messageUserType: .assistant)
        }

        request.httpBody = httpBodyJson

        do {
            if let requestData = try await executeRequest(request: request, withSessionConfig: nil) {
                let jsonStr = String(data: requestData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                print(jsonStr)
                let responseHandler = OpenAIResponseHandler()
                if let messageContent = responseHandler.decodeJson(jsonString: jsonStr)?.choices[0].message["content"] {
                    logMessage(messageContent, messageUserType: .assistant)
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            logMessage("error", messageUserType: .assistant)
        }
    }
}

/// Don't worry about this too much. This just gets rid of errors when using messageLog in a SwiftUI List or ForEach.
extension Dictionary: Identifiable { public var id: UUID { UUID() } }
extension Array: Identifiable { public var id: UUID { UUID() } }
extension String: Identifiable { public var id: UUID { UUID() } }

extension OpenAIConnector {
    private func executeRequest(request: URLRequest, withSessionConfig sessionConfig: URLSessionConfiguration?) async throws -> Data? {
        let session: URLSession
        if let sessionConfig = sessionConfig {
            session = URLSession(configuration: sessionConfig)
        } else {
            session = URLSession.shared
        }

        let (data, _) = try await session.data(for: request)
        guard data.isEmpty == false else {
            print("Error: No data received")
            return nil
        }

        return data
    }
}

public extension OpenAIConnector {
    /// This function makes it simpler to append items to messageLog.
    func logMessage(_ message: String, messageUserType: MessageUserType) {
        var messageUserTypeString = ""
        switch messageUserType {
        case .user:
            messageUserTypeString = "user"
        case .assistant:
            messageUserTypeString = "assistant"
        }

        messageLog.append(["role": messageUserTypeString, "content": message])
    }

    enum MessageUserType {
        case user
        case assistant
    }
}
