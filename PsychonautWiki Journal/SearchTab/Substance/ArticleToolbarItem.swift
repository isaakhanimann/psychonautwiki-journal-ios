import SwiftUI

struct ArticleToolbarItem: ToolbarContent {

    let articleURL: URL?

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if let url = articleURL {
                Link(destination: url) {
                    Label("Article", systemImage: "link")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
    }
}
