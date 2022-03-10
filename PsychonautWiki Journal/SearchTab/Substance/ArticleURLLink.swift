import SwiftUI

struct ArticleURLLink: View {

    let articleURL: URL?

    var body: some View {
        if let url = articleURL {
            Link(destination: url) {
                Label("Article", systemImage: "link")
            }
        } else {
            EmptyView()
        }
    }
}

struct ArticleURLLink_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ArticleURLLink(articleURL: URL(string: "www.apple.com"))
        }
    }
}
