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
            Section {
                InteractionsGroup(
                    interactions: interactions,
                    substanceURL: substanceURL
                )
            }
        }
        .navigationTitle("Interactions")
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
