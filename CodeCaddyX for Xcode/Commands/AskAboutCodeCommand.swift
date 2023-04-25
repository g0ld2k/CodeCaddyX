//
//  AskAboutCodeCommand.swift
//  CodeCaddyX for Xcode
//
//  Created by Chris Golding on 4/24/23.
//

import Foundation
import XcodeKit

class AskAboutCodeCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        try await performInCompanionApp(with: invocation, command: .ask)
    }
}
