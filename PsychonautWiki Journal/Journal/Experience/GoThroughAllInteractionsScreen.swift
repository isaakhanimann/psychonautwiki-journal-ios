//
//  GoThroughAllInteractionsScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 27.12.22.
//

import SwiftUI

struct GoThroughAllInteractionsScreen: View {

    let substancesToCheck: [Substance]

    var body: some View {
        List {
            ForEach(substancesToCheck) { substance in
                Section(substance.name) {
                    if let interactions = substance.interactions {
                        InteractionsGroup(
                            interactions: interactions,
                            substanceURL: substance.url
                        )
                    } else {
                        Text("No documented interactions")
                    }
                }
            }.headerProminence(.increased)
        }.navigationTitle("Interactions")
    }
}

struct GoThroughAllInteractionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoThroughAllInteractionsScreen(
                substancesToCheck: Array(SubstanceRepo.shared.substances.prefix(5))
            )
        }
    }
}
