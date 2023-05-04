//
//  OpenAIHandler.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 5/3/23.
//

import CodeCaddyShared
import Combine
import Foundation

/**
 This class handles OpenAI request and response.
 */
class OpenAIHandler {
    private let openAIService: OpenAIService

    /**
     Initializes a new instance of OpenAIHandler with OpenAIService object.

     - Parameter openAIService: Object of OpenAIService.
     */
    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
    }

    /**
     Sends text to API and returns the response text asynchronously using Combine.

     - Parameter commandText: The command text string.
     - Parameter decodedCodeString: The decoded code string.

     - Returns: Returns a Publisher with Any output and Never failure.
     */
    func sendToAPI(_ commandText: String, _ decodedCodeString: String) async -> AnyPublisher<String, Never> {
        // Add the user's command and decoded code to the OpenAI message log.
        openAIService.addToMessageLog(
            .init(
                role: .user,
                content: "\(commandText)\n\(decodedCodeString)"
            )
        )

        // Start streaming service to OpenAI.
        await openAIService.startChatStreaming()

        // Return a publisher to the latest message on the OpenAI message log.
        return openAIService.$latestMessage
            .eraseToAnyPublisher()
    }
}
