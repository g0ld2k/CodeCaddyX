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
    case badData(reason: String)
    case badJson(reason: String)
    case badParsing(reason: String)
}

public class OpenAIConnector: ObservableObject {
    private enum Constants {
        static let urlString = "https://api.openai.com/v1/chat/completions"
        static let model = "gpt-3.5-turbo"
    }

    /// This URL might change in the future, so if you get an error, make sure to check the OpenAI API Reference.
    let openAIURL = URL(string: Constants.urlString)

    private let defaultMessageLog = [
        /// Modify this to change the personality of the assistant.
        ["role": "system", "content": "You're a friendly, helpful assistant"],
    ]

    /// This is what stores your messages. You can see how to use it in a SwiftUI view here:
    @Published public var messageLog: [[String: String]]

    public init() {
        messageLog = defaultMessageLog
    }

    public func sendToAssistant() async throws {
        guard let apiKey = try? await KeychainService.shared.load(secretKey: KeychainKeys.openAIAPIKey) else {
            logMessage("Error: API Key Not Found.  Please add it in the settings of the CodeCaddyX app.", messageUserType: .assistant)
            return
        }

        var request = URLRequest(url: openAIURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 120 // set timeout to 60 seconds

        let httpBody: [String: Any] = [
            /// In the future, you can use a different chat model here.
            "model": Constants.model,
            "messages": messageLog,
        ]

        var httpBodyJson: Data?

        do {
            httpBodyJson = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        } catch {
            logMessage("Unable to convert to JSON \(error)", messageUserType: .assistant)
        }

        request.httpBody = httpBodyJson

        do {
            guard let responseData = try await executeRequest(request: request, withSessionConfig: nil) else {
                throw OpenAIConnectorError.badData(reason: "Couldn't retrieve data")
            }

            guard let jsonString = String(data: responseData, encoding: .utf8) else {
                throw OpenAIConnectorError.badData(reason: "Couldn't convert data to string")
            }

            let responseHandler = OpenAIResponseDecoder()
            guard let content = responseHandler.decodeJSON(jsonString: jsonString)?.choices.first?.message["content"] else {
                throw OpenAIConnectorError.badParsing(reason: "Couldn't parse message content")
            }

            logMessage(content, messageUserType: .assistant)
        } catch let error as NSError {
            logMessage("Error: \(error.localizedDescription)", messageUserType: .assistant)
        } catch let openAIConnectorError as OpenAIConnectorError {
            logMessage("Error: \(openAIConnectorError.localizedDescription)", messageUserType: .assistant)
        } catch {
            logMessage("Unknown error occurred", messageUserType: .assistant)
        }
    }
}

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
    func logMessage(_ message: String, messageUserType: MessageUserType) {
        messageLog.append(["role": messageUserType.rawValue, "content": message])
    }

    enum MessageUserType: String {
        case user
        case assistant
    }

    func flushLog() {
        messageLog = defaultMessageLog
    }
}
