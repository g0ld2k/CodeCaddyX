// -------------------------------------------------------------------------
//  ContentView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// -------------------------------------------------------------------------

import SwiftUI
import CodeCaddyShared

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
            .onAppear() {
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
            } catch KeychainError.unexpectedStatus(let status) {
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
    var body: some View {
        ScrollView {
            Text("Output:")
                .font(.headline)
            Text("""
                func helloWorld() {
                    print("Hello, world!")
                }
                """)
            .font(.system(.body, design: .monospaced))
        }
        .padding()
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            OutputView()
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
