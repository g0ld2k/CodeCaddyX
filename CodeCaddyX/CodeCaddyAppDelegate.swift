// -------------------------------------------------------------------------
//  IncomingCommandHandler.swift
//  CodeCaddy
//
//  Created by Chris Golding on 2023-04-19.
// -------------------------------------------------------------------------

import AppKit
import Foundation
import SwiftUI

class CodeCaddyAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let incomingCommandHandler = IncomingCommandHandler()

    func applicationWillFinishLaunching(_: Notification) {
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handleAppleEvent(_:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleAppleEvent(_ event: NSAppleEventDescriptor, withReplyEvent _: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
           let url = URL(string: urlString)
        {
            incomingCommandHandler.handleIncomingURL(url)
        }
    }
}
