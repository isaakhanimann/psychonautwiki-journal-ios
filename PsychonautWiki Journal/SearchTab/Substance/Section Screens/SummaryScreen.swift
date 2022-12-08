//
//  SummaryScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct SummaryScreen: View {
    let summary: String

    var body: some View {
        List {
            Section {
                Text(summary)
            }
        }.navigationTitle("Summary")
    }
}

struct SummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SummaryScreen(
                summary: SubstanceRepo.shared.getSubstance(name: "MDMA")!.summary!
            )
        }
    }
}
