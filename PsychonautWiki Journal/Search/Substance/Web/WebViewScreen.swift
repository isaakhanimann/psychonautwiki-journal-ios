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

import MobileCoreServices
import SwiftUI

struct WebViewScreen: View {
    let articleURL: URL
    @State private var isWebViewLoading = true

    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 0) {
                WebViewRepresentable(isLoading: $isWebViewLoading, url: articleURL)
            }
            .toolbar {
                ToolbarItemGroup {
                    ShareLink(item: articleURL)
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

#Preview {
    WebViewScreen(articleURL: URL(string: "https://psychonautwiki.org/wiki/LSD")!)
}
