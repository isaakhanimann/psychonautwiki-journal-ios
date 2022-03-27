import SwiftUI
import MobileCoreServices

struct WebViewSheet: View {

    let articleURL: URL
    @State private var isWebViewLoading = true
    @Environment(\.presentationMode) private var presentationMode
    @State private var isShowingCopySuccess = false

    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 0) {
                toolbar
                WebView(isLoading: $isWebViewLoading, url: articleURL)
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
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

struct WebViewSheet_Previews: PreviewProvider {
    static var previews: some View {
        WebViewSheet(articleURL: URL(string: "https://psychonautwiki.org/wiki/LSD")!)
    }
}
