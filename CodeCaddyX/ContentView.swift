// -------------------------------------------------------------------------
//  ContentView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// -------------------------------------------------------------------------

import CodeCaddyShared
import MarkdownUI
import SwiftUI

struct SettingsView: View {
    @State private var openAiApiKey: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private enum Constants {
        enum Keys {
            static let openAIAPIKey = "openAIAPIKey"
        }
    }

    var body: some View {
        VStack {
            Text("Open AI API Key:")
            TextField("Enter your Open AI API key", text: $openAiApiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Save") {
                saveApiKey()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadApiKey()
            }
        }
        .padding()
    }

    private func saveApiKey() {
        Task.init {
            do {
                try await KeychainService.shared.save(secret: openAiApiKey, secretKey: Constants.Keys.openAIAPIKey)
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func loadApiKey() {
        Task.init {
            do {
                let apiKey = try await KeychainService.shared.load(secretKey: Constants.Keys.openAIAPIKey)
                openAiApiKey = apiKey
            } catch KeychainError.noDataFound {
                return
            } catch KeychainError.dataConversionFailed {
                alertMessage = "Keychain Error: Failed to convert data to the desired format."
                showAlert = true
            } catch let KeychainError.unexpectedStatus(status) {
                alertMessage = "Keychain Error: Unexpected error status: \(status)"
                showAlert = true
            } catch {
                alertMessage = "Keychain Error: Failed to load API key: \(error)"
                showAlert = true
            }
        }
    }
}

struct OutputView: View {
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler

    var body: some View {
        if incomingCommandHandler.isExecuting {
            ProgressView("Asking ChatGPT...")
        } else {
            HStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Input:")
                            Spacer()
                        }
                        .font(.headline)

                        Markdown(incomingCommandHandler.commandInput)
                            .textSelection(.enabled)
                        Spacer()
                    }
                }
                .padding()

                Divider()

                ScrollView {
                    VStack {
                        HStack {
                            Text("Output:")
                            Spacer()
                        }
                        .font(.headline)

                        Markdown(incomingCommandHandler.commandOutput)
                            .textSelection(.enabled)
                        Spacer()
                    }
                }
                .padding()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler

    var body: some View {
        TabView {
            OutputView()
                .environmentObject(incomingCommandHandler)
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Output")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
