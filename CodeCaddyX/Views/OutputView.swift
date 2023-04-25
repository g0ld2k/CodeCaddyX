//
//  OutputView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import CodeCaddyShared
import MarkdownUI
import SwiftUI

/**
 The `OutputView` struct is responsible for displaying incoming command requests. It contains two scrollable views, one for input and one for output. It also shows a progress view when an incoming command is being executed.
 */
struct OutputView: View {
    /**
     The environment object representing incoming command requests.
     */
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler
    @State var question: String = ""
    @State var editorEnabled: Bool = false

    // MARK: - Constants

    private enum Constants {
        static let inputTitle = "Input"
        static let outputTitle = "Output"
    }

    // MARK: - Views

    var body: some View {
        if incomingCommandHandler.isExecuting {
            ProgressView(LocalizedStringKey("Asking ChatGPT..."))
        } else {
            mainView
        }
    }

    /**
     The `mainView` contains two scrollable views, one for input and one for output.
     */
    private var mainView: some View {
        HStack {
            inputView
            Divider()
            outputView
        }
    }

    /**
     The `inputView` contains input title and an input scrollable view of `MarkdownViewerView`.
     */
    private var inputView: some View {
        return VStack {
            Text(Constants.inputTitle)
            ScrollableView {
                MarkdownViewerView(title: "", text: $incomingCommandHandler.commandInput)
            }
            HStack {
                TextEditor(text: $question)
                Button("Send") {
                    incomingCommandHandler.askQuestion(question)
                }
            }

            .padding()
            .onChange(of: incomingCommandHandler.command) { _ in
                editorEnabled = incomingCommandHandler.command == CommandType.ask
            }
        }
    }

    /**
     The `outputView` contains output title and an output scrollable view of `MarkdownViewerView`.
     */
    private var outputView: some View {
        VStack {
            Text(Constants.outputTitle)
            ScrollableView {
                MarkdownViewerView(title: "", text: $incomingCommandHandler.commandOutput)
            }
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
