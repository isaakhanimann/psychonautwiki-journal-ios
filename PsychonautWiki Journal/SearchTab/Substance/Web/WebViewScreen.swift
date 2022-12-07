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
                toolbar
                WebViewRepresentable(isLoading: $isWebViewLoading, url: articleURL)
            }
            if isWebViewLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.accentColor)
            }
        }
    }

    var toolbar: some View {
        HStack {
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

            Spacer()
            Button("Done") {
                dismiss()
            }
        }
        .padding()
    }
}

struct WebViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        WebViewScreen(articleURL: URL(string: "https://psychonautwiki.org/wiki/LSD")!)
    }
}