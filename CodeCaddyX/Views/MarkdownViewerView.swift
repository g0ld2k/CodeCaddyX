//
//  MarkdownViewerView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import MarkdownUI
import SwiftUI

/**
 A view that displays a title and a Markdown-formatted text as its body.
 */
struct MarkdownViewerView: View {
    /// The title to be displayed above the Markdown text.
    var title: String

    /// A binding to the Markdown-formatted text to be displayed.
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(LocalizedStringKey(title))
                Spacer()
            }
            .font(.headline)

            /// Displays the Markdown-formatted text with text selection enabled.
            Markdown(text)
                .textSelection(.enabled)

            Spacer()
        }
        .padding()
    }
}

struct MarkdownViewer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownViewerView(title: "Input", text: .constant("This is my *test* string."))
    }
}
