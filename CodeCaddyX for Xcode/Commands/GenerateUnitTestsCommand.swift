// -------------------------------------------------------------------------
//  GenerateUnitTestsCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
//--------------------------------------------------------------------------

import Foundation
import XcodeKit

class GenerateUnitTestsCommand: BaseCommand {

    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        let commandText = "Create unit tests for the code below. Make sure all non-code is formatted as comments.\n Code begins below here:"

        try await performSelectionCommand(with: invocation, command: commandText, resultType: .bottom, isComment: false)
    }
}
