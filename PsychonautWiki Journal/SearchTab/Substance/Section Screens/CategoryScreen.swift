//
//  CategoryScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct CategoryScreen: View {
    let substance: Substance
    @State private var categories: [Category] = []


    var body: some View {
        List {
            Section {
                ForEach(categories, id: \.name) { category in
                    VStack(alignment: .leading) {
                        Text(category.name.localizedCapitalized).font(.headline)
                        Text(category.description).font(.subheadline)
                        if let articleURL = category.url {
                            NavigationLink {
                                WebViewScreen(articleURL: articleURL)
                            } label: {
                                Label("Article", systemImage: "link")
                            }
                        }
                    }

                }
            }
        }.navigationTitle("Categories")
            .onAppear {
                categories = substance.categories.compactMap { name in
                    SubstanceRepo.shared.categories.first(where: { cat in
                        cat.name == name
                    })
                }
            }
    }
}

struct CategoryScreen_Previews: PreviewProvider {
    static var previews: some View {
        CategoryScreen(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
    }
}
