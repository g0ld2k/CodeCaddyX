//
//  OpenAIService.swift
//  CodeCaddyShared
//
//  Created by Chris Golding on 5/2/23.
//

import Combine
import Foundation
import OpenAIStreamingCompletions

public enum OpenAIServiceError: Error {
    case UnableToFetchAPIKey
}

/**
 An observable object that can be used to communicate with the OpenAI API
 */
public class OpenAIService: ObservableObject {
    /**
      An array of `OpenAIAPI.Message` instances that contains the conversation between the user and the AI generator. We will start with the default message.
     */
    @Published public var messageLog: [OpenAIAPI.Message]

    /**
      A Combine publisher that wraps an OpenAIStreamingCompletions' instance's `text` property. When the property changes, subscribers will be notified.
     */
    @Published public var streamingCompletion: StreamingCompletion?

    /**
      Contains the latest message that has been generated by the AI
     */
    @Published public var latestMessage: String = ""

    private var openAIAPI: OpenAIAPI
    private var subscription: AnyCancellable?
    private var lastUsedAPIKey: String?

    /**
      Initializes an instance of `OpenAIService`
     */
    public init(overrideOpenAIAPI incomingOpenAIAPI: OpenAIAPI? = nil) {
        messageLog = defaultMessageLog

        if let incomingOpenAIAPI {
            openAIAPI = incomingOpenAIAPI
        } else {
            openAIAPI = .init(apiKey: "")
        }

        Task {
            do {
                try await refreshAPIKey()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    /**
      Begins the streaming interaction to generate dialogue
      - Returns: A result with a success value of `Void` on success or an error if this fails
     */
    public func startChatStreaming() async -> Result<Void, Error> {
        do {
            try await refreshAPIKey()

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

    /**
      Adds a message to the message log
      - Parameter message: The message to be added
     */
    public func addToMessageLog(_ message: OpenAIAPI.Message) {
        messageLog.append(message)
    }

    /**
      Flushes the entire message log to the initial default message
     */
    public func flushLog() {
        messageLog = defaultMessageLog
    }

    private let defaultMessageLog: [OpenAIAPI.Message] = [
        .init(role: .system, content: "You're a friendly, helpful assistant"),
    ]

    /**
      Refreshes the API key by loading the value from the keychain
     */
    private func refreshAPIKey() async throws {
        guard let apiKey = try? await KeychainService.shared.load(secretKey: KeychainKeys.openAIAPIKey) else {
            throw OpenAIServiceError.UnableToFetchAPIKey
        }

        if apiKey != lastUsedAPIKey {
            openAIAPI = .init(apiKey: apiKey)
            lastUsedAPIKey = apiKey
        }
    }
}
