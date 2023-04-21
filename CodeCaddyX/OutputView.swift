//
//  OutputView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import MarkdownUI
import SwiftUI

/**
 Represents the output view controller for displaying incoming commands.
 */
struct OutputView: View {
    /**
     The environment object representing incoming command requests.
     */
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler

    // MARK: - Constants

    private let inputTitle = "Input"
    private let outputTitle = "Output"

    // MARK: - Views

    var body: some View {
        if incomingCommandHandler.isExecuting {
            ProgressView(LocalizedStringKey("Asking ChatGPT..."))
        } else {
            mainView
        }
    }

    /**
     The main body of the `OutputView` which contains two scrollable views, one for input and one for output.
     */
    private var mainView: some View {
        HStack {
            scrollableView(title: inputTitle, text: $incomingCommandHandler.commandInput)

            Divider()

            scrollableView(title: outputTitle, text: $incomingCommandHandler.commandOutput)
        }
    }

    // MARK: - Helpers

    /**
     Returns a scrollable view representing a title and corresponding text for the `OutputView`.

     - Parameter title: The title for the corresponding parameter `text`.
     - Parameter text: The text to display in a scrollable view for the corresponding `title`.
     - Returns: A `scrollableView` containing a `title` and corresponding `text` within a `MarkdownViewerView`.
     */
    private func scrollableView(title: String, text: Binding<String>) -> some View {
        ScrollableView {
            MarkdownViewerView(title: title, text: text)
        }
    }
}

struct OutputView_Previews: PreviewProvider {
    static var previews: some View {
        OutputView()
            .environmentObject(IncomingCommandHandler())
    }
}
