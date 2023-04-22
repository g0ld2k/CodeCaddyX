//
//  ScrollableView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import SwiftUI

/**
 A view that displays a scrollable view with vertically stacked content.

 `ScrollableView` provides a convenient and reusable way to display scrollable content with a vertical stack. It takes a view builder that returns the content to be displayed.

 This struct implements the `View` protocol.
 */
struct ScrollableView<Content: View>: View {
    /// The content to be displayed inside the scrollable view.
    let content: Content

    /**
     Initializes a new instance of `ScrollableView`.

     - Parameter content: A closure that returns the content to be displayed inside the scrollable view.

     This initializer takes a closure that returns the content to be displayed inside the scrollable view. The `@ViewBuilder` attribute allows for a more concise trailing closure syntax when initializing.
     */
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /**
     The body of the view.

     This var specifies the content and behavior of the view. In this case, it returns a `ScrollView` with the content arranged in a vertical `VStack`.
     */
    var body: some View {
        ScrollView {
            VStack {
                content
            }
        }
    }
}

struct ScrollableView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollableView {
            Text("Test")
        }
    }
}
