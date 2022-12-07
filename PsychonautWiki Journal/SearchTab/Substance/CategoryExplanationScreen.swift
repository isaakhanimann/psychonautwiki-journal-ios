//
//  CategoryExplanationScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.12.22.
//

import SwiftUI

struct CategoryExplanationScreen: View {

    let categoryName: String
    @State private var category: Category?

    var body: some View {
        List {
            Section {
                Text(category?.description ?? "").navigationTitle(categoryName.localizedCapitalized)
                if let articleURL = category?.url {
                    NavigationLink {
                        WebViewScreen(articleURL: articleURL)
                    } label: {
                        Label("Article", systemImage: "link")
                    }
                }
            }
        }
        .onAppear {
            category = SubstanceRepo.shared.categories.first(where: { cat in
                cat.name == categoryName
            })
        }
    }
}

struct CategoryExplanationScreen_Previews: PreviewProvider {
    static var previews: some View {
        CategoryExplanationScreen(categoryName: "psychedelic")
    }
}
