// -------------------------------------------------------------------------
//  ContentView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// -------------------------------------------------------------------------

import CodeCaddyShared
import MarkdownUI
import SwiftUI

/**
 This struct defines a view that displays a TabView, which renders two sub-views: OutputView and SettingsView.
 */
struct ContentView: View {
    /// A reference to IncomingCommandHandler object that handles incoming commands.
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler

    var body: some View {
        // Display a TabView with two sub-views: OutputView and SettingsView.
        TabView {
            OutputView()
                .environmentObject(incomingCommandHandler)
                .tabItem {
                    Text("Output")
                }
            SettingsView()
                .tabItem {
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(IncomingCommandHandler())
    }
}
