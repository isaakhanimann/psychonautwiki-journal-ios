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
import WrappingHStack

struct CategorySection: View {
    let substance: Substance
    @State private var categories: [Category] = []

    @State private var isAlertShown = false
    @State private var title = ""
    @State private var message = ""
    @State private var articleURL: URL?

    private func showAlert(title: String, message: String, articleURL: URL?) {
        isAlertShown = true
        self.title = title
        self.message = message
        self.articleURL = articleURL
    }

    var body: some View {
        WrappingHStack(
            alignment: .leading,
            horizontalSpacing: 3,
            verticalSpacing: 3
        ) {
            ForEach(categories, id: \.name) { category in
                Button(category.name.localizedCapitalized) {
                    showAlert(title: category.name.localizedCapitalized, message: category.description, articleURL: category.url)
                }.buttonStyle(.bordered)
            }
        }
        .alert(title, isPresented: $isAlertShown, actions: {
            if let articleURL {
                NavigationLink(value: GlobalNavigationDestination.webView(articleURL: articleURL)) {
                    Label("Article", systemImage: "link")
                }
            }
            Button("Ok") {
                isAlertShown = false
            }
        }, message: {
            Text(message)
        })
        .onAppear {
            categories = substance.categories.compactMap { name in
                SubstanceRepo.shared.categories.first(where: { cat in
                    cat.name == name
                })
            }
        }
    }
}

#Preview {
    CategorySection(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
}
