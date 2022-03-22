import SwiftUI

struct WebViewSheet: View {

    let articleURL: URL
    @State private var isWebViewLoading = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 0) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                WebView(isLoading: $isWebViewLoading, url: articleURL)
            }
            if isWebViewLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.accentColor)
            }
        }
    }
}

struct WebViewSheet_Previews: PreviewProvider {
    static var previews: some View {
        WebViewSheet(articleURL: URL(string: "https://psychonautwiki.org/wiki/LSD")!)
    }
}
