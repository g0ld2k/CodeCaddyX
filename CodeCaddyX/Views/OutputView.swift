//
//  OutputView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import CodeCaddyShared
import CodeEditorView
import MarkdownUI
import SwiftUI

/**
 `OutputView` is a struct that displays incoming command requests. It contains two scrollable views: one for input and one for output. It also shows a progress view when an incoming command is being executed.
 */
struct OutputView: View {
    /// The object responsible for handling incoming commands.
    @EnvironmentObject var commandHandler: IncomingCommandHandler
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @State private var position: CodeEditor.Position = .init()
    @State private var messages: Set<Located<Message>> = Set()

    /// The current input question.
    @State private var question = ""

    /// A boolean that determines whether the input view should be expanded.
    @State private var questionInputExpanded = false

    private enum Constant {
        /// The title of the input view.
        static let inputTitle = "Input"

        /// The title of the output view.
        static let outputTitle = "Output"

        /// The width of the toggle and clear buttons.
        static let buttonWidth: CGFloat = 50

        /// The height of the toggle and clear buttons.
        static let buttonHeight: CGFloat = 30

        /// The default height of the input view.
        static let inputViewHeight: CGFloat = 120
    }

    /**
     Sends the current question to the `IncomingCommandHandler`.
     */
    private func send() {
        commandHandler.askQuestion(question)
        question.removeAll()
    }

    /**
     Clears the `IncomingCommandHandler` and the text input.
     */
    private func clear() {
        commandHandler.clear()
        question = ""
    }

    // MARK: - Views

    /// The body of the `OutputView`.
    var body: some View {
        HStack {
            inputView
            Divider()
            ZStack {
                if commandHandler.isExecuting {
                    ProgressView(LocalizedStringKey("Asking ChatGPT..."))
                }
                outputView
            }
        }
    }

    /**
     The `inputView` displays the input title, scrollable input view, toggle button, and clear button.
     */
    private var inputView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(LocalizedStringKey(Constant.inputTitle))
                Spacer()
            }
            .font(.headline)
            .padding()

            CodeEditor(
                text: $commandHandler.commandInput,
                position: $position,
                messages: $messages,
                language: .swift
            )
            .environment(\.codeEditorTheme,
                         colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)

            Divider()
                .padding(.bottom, 4)

            collapsableQuestionInput

            Spacer()
        }
    }

    /**
     The `collapsableQuestionInput` contains a button for expanding and collapsing the text input view. It also contains the text editor if it is expanded or the clear button if it is not expanded.
     */
    private var collapsableQuestionInput: some View {
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

            if questionInputExpanded {
                customEditorView
            } else {
                Button(action: clear) {
                    Text("Clear")
                }.transition(.opacity)
            }
        }
        .onChange(of: commandHandler.command) { newCommand in
            guard let newCommand else { return }
            questionInputExpanded = newCommand == .ask
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
     The `outputView` contains output title and a scrollable view of markdown text.
     */
    private var outputView: some View {
        VStack {
            ScrollableView {
                MarkdownViewerView(title: Constant.outputTitle, text: $commandHandler.commandOutput)
            }
        }
    }
}

struct OutputView_Previews: PreviewProvider {
    static var previews: some View {
        OutputView()
            .environmentObject(IncomingCommandHandler(openAIHandler: .init(openAIService: .init(overrideOpenAIAPI: .init(apiKey: "123456")))))
    }
}
