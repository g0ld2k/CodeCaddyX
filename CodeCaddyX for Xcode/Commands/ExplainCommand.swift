// -------------------------------------------------------------------------
//  ExplainCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// --------------------------------------------------------------------------

import AppKit
import Foundation
import XcodeKit

class ExplainCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
//        let commandText = """
//        Create a comment using DocC formatting that explains the code below. Do not return the inputed code as part of the response.  Only return the comment!  An example response is:
//        /** CodeCaddyX Explanation
//            This function takes in an optional string 'str' as input and then reverses its characters using the 'reversed()' method. If the input string is nil, it returns an empty string. The output is a new string with the characters reversed.
//        **/
//
//        Actual code starts below:
//        """
//        try await performSelectionCommand(with: invocation, command: commandText, resultType: .append, isComment: true)
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
                let customURLString = "codecaddyx://receiveCode?command=explain&code=\(encodedCodeString)"
                if let url = URL(string: customURLString) {
                    // Open the URL to launch the other app
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}
