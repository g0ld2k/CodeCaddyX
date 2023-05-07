//
//  ConvertObjectiveCToSwiftCommand.swift
//  CodeCaddyX for Xcode
//
//  Created by Chris Golding on 5/6/23.
//

import Foundation
import XcodeKit

class ConvertObjectiveCToSwiftCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        try await performInCompanionApp(with: invocation, command: .convertFromObjectiveCToSwift)
    }
}
