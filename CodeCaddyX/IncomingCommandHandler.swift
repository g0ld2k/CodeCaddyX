// -------------------------------------------------------------------------
//  IncomingCommandHandler.swift
//  CodeCaddy
//
//  Created by Chris Golding on 2023-04-19.
// -------------------------------------------------------------------------

import CodeCaddyShared
import Foundation

class IncomingCommandHandler: ObservableObject {
    @Published var commandOutput: String = ""
    @Published var commandInput: String = ""
    @Published var command: String = ""
    @Published var isExecuting: Bool = false

    func handleIncomingURL(_ url: URL) {
        if url.scheme == "codecaddyx" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let codeParam = components.queryItems?.first(where: { $0.name == "code" }),
               let encodedCodeString = codeParam.value,
               let decodedCodeString = encodedCodeString.removingPercentEncoding,
               let commandParam = components.queryItems?.first(where: { $0.name == "command" }),
               let decodedCommandString = commandParam.value?.removingPercentEncoding
            {
                print("Decoded code string: \(decodedCodeString)")

                guard let commandText = getCommandFromText(decodedCommandString) else {
                    commandOutput = "Something went wrong, maybe your command isn't supported?"
                    return
                }
                commandInput = "```\n" + decodedCodeString + "\n```"
                let apiService = OpenAIConnector()

                Task.init {
                    apiService.logMessage("\(commandText)\n\(decodedCodeString)", messageUserType: .user)

                    DispatchQueue.main.async { [weak self] in
                        self?.isExecuting = true
                    }

                    try await apiService.sendToAssistant()

                    DispatchQueue.main.async { [weak self] in
                        self?.isExecuting = false
                    }

                    guard let latestMessage = apiService.messageLog.last else {
                        commandOutput = "That's funny OpenAI didn't send us anything back..."
                        return
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?.commandOutput = latestMessage["content"] ?? "Missing"
                    }
                }
            }
        }
    }

    func getCommandFromText(_ commandRequest: String) -> String? {
        switch commandRequest {
        case "explain":
            return """
                            Create a response using Markdown that explains the code below.
            """
        case "codeReview":
            return """
            How can the code below be better, let me know:
            * How can it be improved to make it more readable, testable, and reduce bugs?
            * Does it make logical sense?
            * Are there any edge cases that have not been handled properly?
            * Provide examples of the code with fixes applied

            The response should be in markdown (but don't mention you are using markdown) and add a header to the output saying this is a code review.
            """
//            return "How can I improve the code below?"
        case "unitTests":
            return """
            Create unit tests for the code below. Ensure all edge cases are covered and let me know if anything can't be tested.
            """
        default:
            return nil
        }
    }
}
