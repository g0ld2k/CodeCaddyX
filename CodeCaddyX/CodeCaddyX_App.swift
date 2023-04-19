// -------------------------------------------------------------------------
//  CodeCaddyX_App.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// -------------------------------------------------------------------------

import SwiftUI

@main
struct CodeCaddyX_App: App {
    @NSApplicationDelegateAdaptor var delegate: CodeCaddyAppDelegate

    var body: some Scene {
        Window("CodeCaddy", id: "main") {
            ContentView()
                .environmentObject(delegate.incomingCommandHandler)
        }
    }
}
