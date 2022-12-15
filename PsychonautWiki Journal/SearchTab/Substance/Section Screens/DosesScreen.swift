//
//  DosesScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct DosesScreen: View {

    let substance: Substance
    
    var body: some View {
        List {
            Section("Disclaimer") {
                Text(ChooseDoseScreen.doseDisclaimer)
            }
            if let remark = substance.dosageRemark {
                Section("\(substance.name) Dosing") {
                    Text(remark)
                }
            }
            ForEach(substance.doseInfos, id: \.route) { doseInfo in
                Section(doseInfo.route.rawValue) {
                    DoseView(roaDose: doseInfo.roaDose)
                    if let bio = doseInfo.bioavailability?.displayString {
                        RowLabelView(label: "Bioavailability", value: "\(bio)%")
                    }
                }
            }
        }.navigationTitle("Dosage")
    }
}

struct DosesScreen_Previews: PreviewProvider {
    static var previews: some View {
        DosesScreen(substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!)
    }
}
