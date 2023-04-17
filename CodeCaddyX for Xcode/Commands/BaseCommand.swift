// -------------------------------------------------------------------------
//  BaseCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
//--------------------------------------------------------------------------

import Foundation
import XcodeKit

class BaseCommand: NSObject, XCSourceEditorCommand {

    enum CommandResult {
        case append
        case replace
        case bottom
    }

    enum CommandError: Error {
        case lineOutOfBounds
        case emptyOutput
    }

    let apiService = OpenAIConnector()

    func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        assertionFailure("This command should not be used directly.  Subclass it and use the appropriate methods")
    }

    func performSelectionCommand(with invocation: XCSourceEditorCommandInvocation, command: String, resultType: CommandResult, isComment: Bool = true) async throws {

        let lines = invocation.buffer.lines as? [String] ?? []

        let selections = invocation.buffer.selections as? [XCSourceTextRange] ?? []
        for selection in selections {
            let indices: [Int] = Array(selection.start.line ... selection.end.line)
            let indexSetOfSelectedCode = IndexSet(integersIn: selection.start.line ... selection.end.line)

            // Get selected text
            var selectedText = ""
            for i in 0 ..< indices.count {
                guard lines.count > indices[i] else { break }
                selectedText += lines[indices[i]]
            }

            print("Selected Text: \n\(selectedText)")

            apiService.logMessage("\(command)\n\(selectedText)", messageUserType: .user)

            try await apiService.sendToAssistant()

            guard let latestMessage = apiService.messageLog.last else {
                throw CommandError.emptyOutput
            }

            let contentForXcode = formatOutput(content: latestMessage["content"], isComment: isComment)

            switch resultType {
            case .replace:
                invocation.buffer.lines.removeObjects(at: indexSetOfSelectedCode)
                invocation.buffer.lines.insert(contentForXcode, at: indices[0])
            case .append:
                invocation.buffer.lines.insert(contentForXcode, at: indices[0])
            case .bottom:
                invocation.buffer.lines.add(contentForXcode)
            }
            return
        }
    }

    private func formatOutput(content: String?, isComment: Bool = true) -> String {
        guard let content, content.isEmpty == false else {
            return "ChatGPT gave us nothing..."
        }

        if isComment {
            return formatOutputComment(content: content)
        }

        return content
    }

    private func formatOutputComment(content: String) -> String {
        var contentAsComment = content
        if content.hasPrefix("/*") == false &&
            content.hasPrefix("//") == false {
            contentAsComment = "/**\n" + content
        }

        if contentAsComment.hasPrefix("//") == false &&
            checkIfAllCommentsHaveBeenClosed(str: contentAsComment) == false {
            contentAsComment = contentAsComment + "\n**/"
        }

        return contentAsComment
    }

    private func checkIfAllCommentsHaveBeenClosed(str: String) -> Bool {
        let pattern = #"/\*.*?\*/"# // Match comments
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let range = NSRange(str.startIndex..., in: str)
        let matches = regex.matches(in: str, options: [], range: range)
        return matches.allSatisfy { match in
            let commentRange = match.range
            let comment = (str as NSString).substring(with: commentRange)
            return comment.hasSuffix("*/")
        }
    }
}
