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
    @Published var command: CommandType?
    @Published var isExecuting: Bool = false

    private enum Constants {
        static let urlScheme = "codecaddyx"
        enum Params {
            static let code = "code"
            static let command = "command"
            static let remember = "remember"
        }
    }

    /**
     Dictionary that maps a `CommandType` to a command string.
     */
    private let commands: [CommandType: String] = [
        .explain: "Create a response using Markdown that explains the code below.",
        .codeReview: """
            How can the code below be better, let me know:
            * How can it be improved to make it more readable, testable, and reduce bugs?
            * Does it make logical sense?
            * Are there any edge cases that have not been handled properly?
            * Provide examples of the code with fixes applied

            The response should be in markdown (but don't mention you are using markdown) and add a header to the output saying this is a code review.
        """,
        .unitTests: """
            Create unit tests for the code below. Ensure all edge cases are covered and let me know if anything can't be tested.
        """,
    ]

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
              let encodedBase64CodeString = codeParam.value?.removingPercentEncoding,
              let dataFromCodeString = Data(base64Encoded: encodedBase64CodeString),
              let decodedCodeString = String(data: dataFromCodeString, encoding: .utf8),
              let commandParam = components.queryItems?.first(where: { $0.name == Constants.Params.command }),
              let decodedCommandString = commandParam.value?.removingPercentEncoding,
              let commandType = CommandType(rawValue: decodedCommandString)
        else {
            return
        }

        handleCommand(decodedCodeString, commandType, rememberCommand: false)
    }

    /**
     Ask a question to the OpenAI assistant.

     - Parameters:
        - question: The question to ask.
     */
    func askQuestion(_ question: String) {
        openAIConnector.logMessage("\(commandInput)\n\n\(question)", messageUserType: .user)

        sendToAPI()
    }

    /**
     Clears both the command input and command output, as well as the message log in `OpenAIConnector`.
     */
    func clear() {
        commandInput = ""
        commandOutput = ""
        openAIConnector.flushLog()
    }

    /**
     Handles the command based on the command text received.

     - Parameters:
        - decodedCodeString: The decoded code string.
        - commandString: The decoded command string.
     */
    private func handleCommand(_ decodedCodeString: String, _ commandType: CommandType, rememberCommand: Bool = false) {
        switch commandType {
        case .explain, .codeReview, .unitTests:
            handleClosedCommand(decodedCodeString, commandType, rememberCommand: rememberCommand)
        case .ask:
            handleOpenEndedCommand(decodedCodeString)
        }
    }

    /**
     Handles a closed command (command that does not require the user to respond)

     - Parameters:
        - decodedCodeString: The decoded code string.
        - commandString: The decoded command string.
        - rememberCommand: Whether the command should be remembered in the `OpenAIConnector` log.
     */
    private func handleClosedCommand(_ decodedCodeString: String, _ commandType: CommandType, rememberCommand: Bool = false) {
        guard let commandText = commands[commandType] else {
            commandOutput = "Something went wrong, maybe your command isn't supported?"
            return
        }

        if rememberCommand == false {
            openAIConnector.flushLog()
        }

        commandInput = "```\n" + decodedCodeString + "\n```"

        openAIConnector.logMessage("\(commandText)\n\(decodedCodeString)", messageUserType: .user)

        sendToAPI()
    }

    /**
     Handles an open-ended command (command that allows the user to ask follow up responses)

     - Parameters:
        - decodedCodeString: The decoded code string.
        - commandString: The decoded command string.
        - rememberCommand: Whether the command should be remembered in the `OpenAIConnector` log.
     */
    private func handleOpenEndedCommand(_ decodedCodeString: String) {
        commandInput = decodedCodeString
    }

    /**
     Sends data to the `OpenAIConnector` and waits for a response. Once received, updates the command output accordingly.
     */
    private func sendToAPI() {
        Task.init {
            DispatchQueue.main.async { [weak self] in
                self?.isExecuting = true
                self?.commandOutput = ""
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
        }
    }
}
