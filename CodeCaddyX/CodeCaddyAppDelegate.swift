// -------------------------------------------------------------------------
//  IncomingCommandHandler.swift
//  CodeCaddy
//
//  Created by Chris Golding on 2023-04-19.
// -------------------------------------------------------------------------

import AppKit
import CodeCaddyShared
import Foundation
import OpenAIStreamingCompletions
import SwiftUI

/**
 A delegate that manages application-level events.

 This delegate conforms to `NSApplicationDelegate` and `ObservableObject`. It handles incoming URLs by forwarding
 them to the `IncomingCommandHandler` instance.

 Declare an instance of `CodeCaddyAppDelegate()` in your app's main file to initialize and use this delegate.
 */
class CodeCaddyAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    /// An instance of `IncomingCommandHandler` for handling incoming URLs.
    var incomingCommandHandler: IncomingCommandHandler

    override init() {
        incomingCommandHandler = .init(openAIHandler: .init(openAIService: .init()))
        super.init()
    }

    /**
     Handle `kAEGetURL` events by calling `IncomingCommandHandler.handleIncomingURL(_:url)` on the `incomingCommandHandler` instance.

     - Parameters:
     - event: The incoming Apple event.
     - replyEvent: (Unused) The outgoing Apple event.
     */
    @objc func handleAppleEvent(_ event: NSAppleEventDescriptor, withReplyEvent _: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else { return }
        incomingCommandHandler.handleIncomingURL(url)
    }

    /**
     Register the `CodeCaddyAppDelegate` instance as the handler for `kAEGetURL` events.

     This method gets called automatically by `AppDelegate` when the application has finished launching.
     */
    func applicationWillFinishLaunching(_: Notification) {
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handleAppleEvent(_:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))
    }
}
