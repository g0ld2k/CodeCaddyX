// -------------------------------------------------------------------------
//  IncomingCommandHandler.swift
//  CodeCaddy
//
//  Created by Chris Golding on 2023-04-19.
// -------------------------------------------------------------------------

import CodeCaddyShared
import Foundation

/**
 A struct representing a command.

 - Parameters:
    - type: The command type.
    - commandText: The text for the command.
 */
struct Command {
    let type: CommandType
    let commandText: String
}

/**
 Handler for processing incoming commands from Xcode Extension
 */
class IncomingCommandHandler: ObservableObject {
    @Published var commandOutput: String = ""
    @Published var commandInput: String = ""
    @Published var command: String = ""
    @Published var isExecuting: Bool = false

    private enum Constants {
        static let urlScheme = "codecaddyx"
        enum Params {
            static let code = "code"
            static let command = "command"
            static let remember = "remember"
        }
    }

    private let openAIConnector = OpenAIConnector()

    /**
     Handles incoming command URLs from the `URL` provided.

     - Parameters:
        - url: The URL received.
     */
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == Constants.urlScheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let codeParam = components.queryItems?.first(where: { $0.name == Constants.Params.code }),
              let encodedCodeString = codeParam.value,
              let decodedCodeString = encodedCodeString.removingPercentEncoding,
              let commandParam = components.queryItems?.first(where: { $0.name == Constants.Params.command }),
              let decodedCommandString = commandParam.value?.removingPercentEncoding
        else {
            return
        }
        
        let rememberMessage: Bool
        if let rememberParam = components.queryItems?.first(where: { $0.name == Constants.Params.remember }),
           let rawValue = rememberParam.value,
           let value = Bool(rawValue) {
            rememberMessage = value
        } else {
            rememberMessage = false
        }

        handleCommand(decodedCodeString, decodedCommandString)
    }

    /**
     Handles the command based on the command text received.

     - Parameters:
        - decodedCodeString: The decoded code string.
        - commandString: The decoded command string.
     */
    private func handleCommand(_ decodedCodeString: String, _ commandString: String?, rememberCommand: Bool = false) {
        guard let commandText = getCommandFromText(commandString) else {
            commandOutput = "Something went wrong, maybe your command isn't supported?"
            return
        }

        commandInput = "```\n" + decodedCodeString + "\n```"

        Task.init {
            openAIConnector.logMessage("\(commandText)\n\(decodedCodeString)", messageUserType: .user)

            DispatchQueue.main.async { [weak self] in
                self?.isExecuting = true
            }

            try await openAIConnector.sendToAssistant()

            DispatchQueue.main.async { [weak self] in
                self?.isExecuting = false
            }

            guard let latestMessage = openAIConnector.messageLog.last else {
                commandOutput = "That's funny OpenAI didn't send us anything back..."
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.commandOutput = latestMessage["content"] ?? "Missing"
            }
            
            if rememberCommand == false {
                openAIConnector.flushLog()
            }
        }
    }

    /**
     Retrieves the correct command text based on the command request.

     - Parameter:
        - commandRequest: The command requested.

     - Returns: The correct command text or `nil` if it does not exist.
     */
    private func getCommandFromText(_ commandRequest: String?) -> String? {
        guard let commandRequest,
              let commandType = CommandType(rawValue: commandRequest) else { return nil }

        let commands = [
            Command(type: .explain, commandText: "Create a response using Markdown that explains the code below."),
            Command(type: .codeReview, commandText: """
            How can the code below be better, let me know:
            * How can it be improved to make it more readable, testable, and reduce bugs?
            * Does it make logical sense?
            * Are there any edge cases that have not been handled properly?
            * Provide examples of the code with fixes applied

            The response should be in markdown (but don't mention you are using markdown) and add a header to the output saying this is a code review.
            """),
            Command(type: .unitTests, commandText: """
            Create unit tests for the code below. Ensure all edge cases are covered and let me know if anything can't be tested.
            """),
        ]

        return commands.first(where: { $0.type == commandType })?.commandText
    }
}
