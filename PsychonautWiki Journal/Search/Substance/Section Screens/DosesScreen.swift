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
                Section(
                    header: Text(doseInfo.route.rawValue),
                    footer: Text(DosesScreen.getUnitClarification(for: doseInfo.roaDose.units))
                ) {
                    DoseRow(roaDose: doseInfo.roaDose)
                    if let bio = doseInfo.bioavailability?.displayString {
                        RowLabelView(label: "Bioavailability", value: "\(bio)%")
                    }
                }
            }
        }.navigationTitle("Dosage")
    }

    

    static func getUnitClarification(for units: String) -> String {
        if units == "µg" {
            return "1 µg = 1/1000 mg = 1/1'000'000 gram"
        } else if units == "mg" {
            return "1 mg = 1/1000 gram"
        } else if units == "mL" {
            return "1 mL = 1/1000 L"
        } else {
            return ""
        }
    }
}

struct DosesScreen_Previews: PreviewProvider {
    static var previews: some View {
        DosesScreen(substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!)
    }
}
