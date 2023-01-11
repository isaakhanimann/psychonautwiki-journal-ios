// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

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
            }
        }
    }
}

struct WebViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        WebViewScreen(articleURL: URL(string: "https://psychonautwiki.org/wiki/LSD")!)
    }
}
