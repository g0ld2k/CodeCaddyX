// -------------------------------------------------------------------------
//  GenerateUnitTestsCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// --------------------------------------------------------------------------

import AppKit
import Foundation
import XcodeKit

class GenerateUnitTestsCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
//        let commandText = "Create unit tests for the code below. Make sure all non-code is formatted as comments.\n Code begins below here:"
//
//        try await performSelectionCommand(with: invocation, command: commandText, resultType: .bottom, isComment: false)

        let lines = invocation.buffer.lines as? [String] ?? []

        let selections = invocation.buffer.selections as? [XCSourceTextRange] ?? []
        for selection in selections {
            let indices: [Int] = Array(selection.start.line ... selection.end.line)

            // Get selected text
            var selectedText = ""
            for i in 0 ..< indices.count {
                guard lines.count > indices[i] else { break }
                selectedText += lines[indices[i]]
            }

            if let encodedCodeString = selectedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let customURLString = "codecaddyx://receiveCode?command=unitTests&code=\(encodedCodeString)"
                if let url = URL(string: customURLString) {
                    // Open the URL to launch the other app
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}
