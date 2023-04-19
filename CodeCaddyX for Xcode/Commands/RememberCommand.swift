

import Foundation
import XcodeKit
import AppKit

class RememberCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {

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
