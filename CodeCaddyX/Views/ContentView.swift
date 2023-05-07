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
A view that handles and displays the output from `IncomingCommandHandler`.
*/
struct ContentView: View {
    /**
    A reference to `IncomingCommandHandler` object that handles incoming commands.
    */
    @EnvironmentObject var incomingCommandHandler: IncomingCommandHandler
    
    var body: some View {
        OutputView()
            .environmentObject(incomingCommandHandler)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(IncomingCommandHandler(openAIHandler: .init(openAIService: .init(overrideOpenAIAPI: .init(apiKey: "123456")))))
    }
}
