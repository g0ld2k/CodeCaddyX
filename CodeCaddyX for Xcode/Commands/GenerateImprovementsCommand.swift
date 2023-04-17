// -------------------------------------------------------------------------
//  GenerateImprovementsCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
//--------------------------------------------------------------------------

import Foundation
import XcodeKit

class GenerateImprovementsCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {

        let command = """
Perform a code review on the code below.  How can it be improved to make it more readable and reduce bugs? The response should come as a comment formatted using DocC formatting (but don't mention you are using DocC formatting).  The entire response, including the code itself should begin with /* and end with */, ensure all comments are closed properly.  The output of this will be a comment placed above the submitted code.

An example of how I'd like this formatted is:

/** CodeCaddyX Response:
/**
 A method to reverse a given string.
 - Parameter str: The string to reverse.
 - Returns: The reversed string or an empty string if the input string is nil.
 */
func doSomething(str: String?) -> String {
    // Use optional binding to make sure the input string is not nil
    guard let str = str else {
        return ""
    }

    // Use the `reversed()` method to reverse the string
    return String(str.reversed())
}

/*
 Comments from your friendly assistant:
 - Good job with adding a parameter description.
 - Remember to use guard statements for optional unwrapping instead of if-let statements to reduce unnecessary nesting.
 - Consider explicitly stating the return type instead of relying on type inference for better readability.
 - Keep up the good work! */
 **/

The code to analyze is below:

"""

        try await performSelectionCommand(with: invocation, command: command, resultType: .append, isComment: true)
    }
}

