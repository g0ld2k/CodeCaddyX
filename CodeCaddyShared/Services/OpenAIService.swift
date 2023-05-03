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
    private var openAIAPI: OpenAIAPI
    private var subscription: AnyCancellable?

    @Published public var messageLog: [OpenAIAPI.Message]
    @Published public var streamingCompletion: StreamingCompletion?
    @Published public var latestMessage: String = ""

    public init(openAIAPI incomingOpenAIAPI: OpenAIAPI? = nil) {
        messageLog = defaultMessageLog

        if let incomingOpenAIAPI {
            openAIAPI = incomingOpenAIAPI
        } else {
            openAIAPI = .init(apiKey: "")
        }

        Task {
            let apiKey = try await KeychainService.shared.load(secretKey: KeychainKeys.openAIAPIKey)
            self.openAIAPI = .init(apiKey: apiKey)
        }
    }

    public func startChatStreaming() -> Result<Void, Error> {
        do {
            streamingCompletion = try openAIAPI.completeChatStreamingWithObservableObject(.init(messages: messageLog))

            subscription = streamingCompletion?
                .$text
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] text in
                    self?.latestMessage = text
                })
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func addToMessageLog(_ message: String, type: OpenAIAPI.Message.Role) {
        messageLog.append(.init(role: type, content: message))
    }

    public func flushLog() {
        messageLog = defaultMessageLog
    }
}
