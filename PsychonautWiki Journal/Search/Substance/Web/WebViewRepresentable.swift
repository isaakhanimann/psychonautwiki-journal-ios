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
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    @Binding var isLoading: Bool
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(isLoading: $isLoading)
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    @Binding var isLoading: Bool

    init(isLoading: Binding<Bool>) {
        _isLoading = isLoading
    }

    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        isLoading = true
    }

    func webView(_: WKWebView, didCommit _: WKNavigation!) {
        isLoading = false
    }
}
