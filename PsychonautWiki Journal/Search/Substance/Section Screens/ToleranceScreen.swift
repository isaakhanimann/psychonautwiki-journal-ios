//
//  ToleranceScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct ToleranceScreen: View {
    let substance: Substance

    var body: some View {
        List {
            Section(footer: Text("* zero is the time to no tolerance")) {
                if let full = substance.tolerance?.full {
                    RowLabelView(label: "full", value: full)
                }
                if let half = substance.tolerance?.half {
                    RowLabelView(label: "half", value: half)
                }
                if let zero = substance.tolerance?.zero {
                    RowLabelView(label: "zero", value: zero)
                }
                let crossTolerances = substance.crossTolerances.joined(separator: ", ")
                if !crossTolerances.isEmpty {
                    Text("Cross tolerance with \(crossTolerances)")
                }
            }
        }.navigationTitle("Tolerance")
    }
}

struct ToleranceScreen_Previews: PreviewProvider {
    static var previews: some View {
        ToleranceScreen(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
    }
}
