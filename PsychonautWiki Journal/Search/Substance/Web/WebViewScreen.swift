import SwiftUI
import MobileCoreServices

struct WebViewScreen: View {

    let articleURL: URL
    @State private var isWebViewLoading = true
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCopySuccess = false

    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 0) {
                WebViewRepresentable(isLoading: $isWebViewLoading, url: articleURL)
            }.toolbar {
                ToolbarItemGroup {
                    if #available(iOS 16.0, *) {
                        ShareLink(item: articleURL)
                    } else {
                        if !isShowingCopySuccess {
                            Button {
                                UIPasteboard.general.setValue(articleURL.absoluteString, forPasteboardType: "public.plain-text")
                                isShowingCopySuccess = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    isShowingCopySuccess = false
                                }
                            } label: {
                                Label("Copy Link", systemImage: "doc.on.doc")
                            }
                        } else {
                            Label("Link Copied", systemImage: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    Link(destination: articleURL) {
                        Label("Open in Safari", systemImage: "safari")
                    }
                }
            }
            if isWebViewLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.accentColor)
            }
        }
    }
}

struct WebViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        WebViewScreen(articleURL: URL(string: "https://psychonautwiki.org/wiki/LSD")!)
    }
}
