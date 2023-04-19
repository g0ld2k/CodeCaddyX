

import Foundation
import AppKit
import SwiftUI

class CodeCaddyAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
//    var window: NSWindow!

    let incomingCommandHandler = IncomingCommandHandler()

//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        let contentView = ContentView().environmentObject(incomingCommandHandler)
//
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered,
//            defer: false
//        )
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
//    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handleAppleEvent(_:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleAppleEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
           let url = URL(string: urlString) {
            incomingCommandHandler.handleIncomingURL(url)
        }
    }
}
