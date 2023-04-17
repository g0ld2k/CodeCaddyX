// -------------------------------------------------------------------------
//  ExplainCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// --------------------------------------------------------------------------

import Foundation
import XcodeKit

class ExplainCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        let commandText = """
        Create a comment using DocC formatting that explains the code below. Do not return the inputed code as part of the response.  Only return the comment!  An example response is:
        /** CodeCaddyX Explanation
            This function takes in an optional string 'str' as input and then reverses its characters using the 'reversed()' method. If the input string is nil, it returns an empty string. The output is a new string with the characters reversed.
        **/

        Actual code starts below:
        """
        try await performSelectionCommand(with: invocation, command: commandText, resultType: .append, isComment: true)
    }
}
