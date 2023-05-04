// -------------------------------------------------------------------------
//  AddCommentsToCodeCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// -------------------------------------------------------------------------

import Foundation
import XcodeKit

class AddCommentsToCodeCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        let command = "Add comments to the following code using DocC formatting: "
        try await performSelectionCommand(with: invocation, command: command, resultType: .replace, isComment: false)
    }
}

class AddCommentsToCodeInAppCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        try await performInCompanionApp(with: invocation, command: .document)
    }
}
