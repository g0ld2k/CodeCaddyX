//
//  MarkdownViewerView.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 4/20/23.
//

import MarkdownUI
import SwiftUI

struct MarkdownViewerView: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack {
            HStack {
                Text(LocalizedStringKey(title))
                Spacer()
            }
            .font(.headline)

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
