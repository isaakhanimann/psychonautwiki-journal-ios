//
//  InteractionsScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct InteractionsScreen: View {
    let interactions: Interactions
    let substanceURL: URL

    var body: some View {
        List {
            InteractionSection(
                interactions: interactions,
                substanceURL: substanceURL
            )
        }
        .navigationTitle("Interactions")
    }
}

struct InteractionSection: View {
    let interactions: Interactions
    let substanceURL: URL

    var body: some View {
        Section {
            let iconName = "exclamationmark.triangle"
            ForEach(interactions.dangerous, id: \.self) { name in
                HStack(spacing: 0) {
                    Text(name)
                    Spacer()
                    Image(systemName: iconName)
                    Image(systemName: iconName)
                    Image(systemName: iconName)
                }
            }.foregroundColor(InteractionType.dangerous.color)
            ForEach(interactions.unsafe, id: \.self) { name in
                HStack(spacing: 0) {
                    Text(name)
                    Spacer()
                    Image(systemName: iconName)
                    Image(systemName: iconName)
                }
            }.foregroundColor(InteractionType.unsafe.color)
            ForEach(interactions.uncertain, id: \.self) { name in
                HStack(spacing: 0) {
                    Text(name)
                    Spacer()
                    Image(systemName: iconName)
                }
            }.foregroundColor(InteractionType.uncertain.color)
            if let interactionURL = URL(string: substanceURL.absoluteString + "#Dangerous_interactions") {
                NavigationLink {
                    WebViewScreen(articleURL: interactionURL)
                } label: {
                    Label("Explanations", systemImage: "info.circle")
                }
            }
        }
    }
}

struct InteractionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        InteractionsScreen(
            interactions: SubstanceRepo.shared.getSubstance(name:"MDMA")!.interactions!,
            substanceURL: URL(string: "www.apple.com")!
        )
    }
}
