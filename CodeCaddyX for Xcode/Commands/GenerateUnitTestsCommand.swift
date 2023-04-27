// -------------------------------------------------------------------------
//  GenerateUnitTestsCommand.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// --------------------------------------------------------------------------

import AppKit
import CodeCaddyShared
import Foundation
import XcodeKit

class GenerateUnitTestsCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        try await performInCompanionApp(with: invocation, command: .unitTests)
    }
}
