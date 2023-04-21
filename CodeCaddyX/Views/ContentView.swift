// -------------------------------------------------------------------------
//  ContentView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-13.
// -------------------------------------------------------------------------

import CodeCaddyShared
import MarkdownUI
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler

    var body: some View {
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
