//
//  OpenAIHandler.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 5/3/23.
//

import CodeCaddyShared
import Combine
import Foundation

class OpenAIHandler {
    private let openAIService: OpenAIService

    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
    }

    func sendToAPI(_ commandText: String, _ decodedCodeString: String) -> AnyPublisher<String, Never> {
        openAIService.addToMessageLog("\(commandText)\n\(decodedCodeString)", type: .user)
        openAIService.startChatStreaming()

        return openAIService.$latestMessage
            .eraseToAnyPublisher()
    }
}
