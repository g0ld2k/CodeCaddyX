//
//  SettingsView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import CodeCaddyShared
import SwiftUI

/**
 A view for managing user settings, including Open AI API key.
 */
struct SettingsView: View {
    // MARK: Properties

    @State private var openAiApiKey: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    // MARK: Constants

    private enum Constants {
        enum Keys {
            static let openAIAPIKey = "openAIAPIKey"
        }
    }

    // MARK: Body

    var body: some View {
        VStack {
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
        .frame(width: 480, height: 320)
    }

    // MARK: Actions

    /**
     Saves user's Open AI API key in keychain.
     */
    private func saveApiKey() {
        guard !openAiApiKey.isEmpty else {
            alertMessage = "Please enter Open AI API"
            showAlert = true
            return
        }

        Task.init {
            do {
                try await KeychainService.shared.save(secret: openAiApiKey, secretKey: Constants.Keys.openAIAPIKey)
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    /**
     Loads user's Open AI API key from keychain.
     */
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
