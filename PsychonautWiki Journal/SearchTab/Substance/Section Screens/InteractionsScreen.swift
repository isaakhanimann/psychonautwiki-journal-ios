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
        InteractionList(
            interactions: interactions,
            substanceURL: substanceURL
        ).navigationTitle("Interactions")
    }
}

struct InteractionList: View {
    let interactions: Interactions
    let substanceURL: URL

    var body: some View {
        List {
            if let interactionURL = URL(string: substanceURL.absoluteString + "#Dangerous_interactions") {
                Section("Explanations") {
                    NavigationLink {
                        WebViewScreen(articleURL: interactionURL)
                    } label: {
                        Label("Article", systemImage: "link")
                    }
                }
            }
            if !interactions.dangerous.isEmpty {
                Section("Dangerous") {
                    DangerousInteractions(dangerousInteractions: interactions.dangerous)
                }
            }
            if !interactions.unsafe.isEmpty {
                Section("Unsafe") {
                    UnsafeInteractions(unsafeInteractions: interactions.unsafe)
                }
            }
            if !interactions.uncertain.isEmpty {
                Section("Uncertain") {
                    UncertainInteractions(uncertainInteractions: interactions.uncertain)
                }
            }
        }
    }
}

let iconName = "exclamationmark.triangle"

struct DangerousInteractions: View {
    let dangerousInteractions: [String]

    var body: some View {
        ForEach(dangerousInteractions, id: \.self) { name in
            HStack(spacing: 0) {
                Text(name)
                Spacer()
                Image(systemName: iconName)
                Image(systemName: iconName)
                Image(systemName: iconName)
            }
        }.foregroundColor(InteractionType.dangerous.color)
    }
}

struct UnsafeInteractions: View {
    let unsafeInteractions: [String]

    var body: some View {
        ForEach(unsafeInteractions, id: \.self) { name in
            HStack(spacing: 0) {
                Text(name)
                Spacer()
                Image(systemName: iconName)
                Image(systemName: iconName)
            }
        }.foregroundColor(InteractionType.unsafe.color)
    }
}

struct UncertainInteractions: View {
    let uncertainInteractions: [String]

    var body: some View {
        ForEach(uncertainInteractions, id: \.self) { name in
            HStack(spacing: 0) {
                Text(name)
                Spacer()
                Image(systemName: iconName)
            }
        }.foregroundColor(InteractionType.uncertain.color)
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
