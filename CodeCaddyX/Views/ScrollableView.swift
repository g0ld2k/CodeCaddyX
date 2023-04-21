//
//  ScrollableView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import SwiftUI

struct ScrollableView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

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
