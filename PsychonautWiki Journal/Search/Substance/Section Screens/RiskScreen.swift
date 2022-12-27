//
//  RiskScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct RiskScreen: View {
    let substance: Substance
    var body: some View {
        List {
            if let acute = substance.generalRisks {
                Section("Acute") {
                    Text(acute)
                }
            }
            if let longTerm = substance.longtermRisks {
                Section("Long-term") {
                    Text(longTerm)
                }
            }
        }.navigationTitle("Risks")
    }
}

struct RiskScreen_Previews: PreviewProvider {
    static var previews: some View {
        RiskScreen(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
    }
}
