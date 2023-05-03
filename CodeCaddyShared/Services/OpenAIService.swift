//
//  OpenAIService.swift
//  CodeCaddyShared
//
//  Created by Chris Golding on 5/2/23.
//

import Combine
import Foundation
import OpenAIStreamingCompletions

public class OpenAIService: ObservableObject {
    private let defaultMessageLog: [OpenAIAPI.Message] = [
        .init(role: .system, content: "You're a friendly, helpful assistant"),
    ]
    private var api: OpenAIAPI
    private var subscription: AnyCancellable?

    @Published public var messageLog: [OpenAIAPI.Message]
    @Published public var streamingCompletion: StreamingCompletion?
    @Published public var latestMessage: String = ""

    public init() {
        messageLog = defaultMessageLog
        api = OpenAIAPI(apiKey: "")

        Task {
            let apiKey = try await KeychainService.shared.load(secretKey: KeychainKeys.openAIAPIKey)
            api = OpenAIAPI(apiKey: apiKey)
        }
    }

    public func sendToAssistant() throws {
        streamingCompletion = try api.completeChatStreamingWithObservableObject(.init(messages: messageLog))

        subscription = streamingCompletion?
            .$text
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                print("Text: \(text)")
                self?.latestMessage = text
            })
    }

    public func addToMessageLog(_ message: String, type: OpenAIAPI.Message.Role) {
        messageLog.append(.init(role: type, content: message))
    }

    public func flushLog() {
        messageLog = defaultMessageLog
    }
}
