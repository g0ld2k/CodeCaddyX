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
    @EnvironmentObject var commandHandler: IncomingCommandHandler
    @State private var question = ""
    @State private var editorEnabled = false
    @State private var questionInputExpanded = true

    private enum Constant {
        static let inputTitle = "Input"
        static let outputTitle = "Output"
        static let buttonWidth: CGFloat = 50
        static let buttonHeight: CGFloat = 30
        static let inputViewHeight: CGFloat = 120
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
    
    /**
     Sends the current question to the `IncomingCommandHandler`.
     */
    private func send() {
        commandHandler.askQuestion(question)
    }
    
    /**
     Clears the `IncomingCommandHandler` and the text input.
     */
    private func clear() {
        commandHandler.clear()
        question = ""
    }

    // MARK: - Views

    var body: some View {
        ZStack {
            // Show progress view when a command is being executed
            if commandHandler.isExecuting {
                ProgressView(LocalizedStringKey("Asking ChatGPT..."))
            }
            mainView
        }
    }

    /**
     The `inputView` contains the input title, scrollable input view, toggle button, and clear button.
     */
    private var inputView: some View {
        VStack(spacing: 0) {
            // Scrollable input view
            scrollableView(title: Constant.inputTitle, text: $commandHandler.commandInput)
            // Divider and toggle button
            Divider()
                .padding(.bottom, 4)
            toggleButton
            Spacer()
        }
    }

    /**
     The `toggleButton` contains a button for expanding and collapsing the text input view, as well as the text editor if it is expanded, or the clear button if it is not expanded.
     */
    private var toggleButton: some View {
        HStack {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        questionInputExpanded.toggle()
                    }
                } label: {
                    Image(systemName: questionInputExpanded ? "chevron.down" : "chevron.up")
                }
                .padding(.leading)
            }
            // Show text editor if expanded, or clear button if not expanded
            if questionInputExpanded {
                customEditorView
            } else {
                Button(action: clear) {
                    Text("Clear")
                }.transition(.opacity)
            }
        }
    }

    /**
     The `customEditorView` allows users to edit and send a custom question to the `IncomingCommandHandler`.
     */
    private var customEditorView: some View {
        HStack {
            TextEditor(text: $question)
                .font(.body)
                .padding(.all, 8)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
                .shadow(radius: 2)
                .frame(height: Constant.inputViewHeight)
                .transition(.slide)
            
            VStack {
                Button("Send", action: send)
                    .frame(width: Constant.buttonWidth, height: Constant.buttonHeight)
                Button("Clear", action: clear)
                    .frame(width: Constant.buttonWidth, height: Constant.buttonHeight)
            }
            .transition(.slide)
        }
    }

    /**
     The `outputView` contains output title and an output scrollable view of `MarkdownViewerView`.
     */
    private var outputView: some View {
        VStack {
            Text(Constant.outputTitle)
            ScrollableView {
                MarkdownViewerView(title: "", text: $commandHandler.commandOutput)
            }
        }
    }
}

struct OutputView_Previews: PreviewProvider {
    static var previews: some View {
        OutputView()
            .environmentObject(IncomingCommandHandler())
    }
}
