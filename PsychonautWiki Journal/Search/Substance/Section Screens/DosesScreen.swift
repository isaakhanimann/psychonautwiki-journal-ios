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
            if let remark = substance.dosageRemark {
                Section("\(substance.name) Dosing") {
                    Text(remark)
                }
            }
            ForEach(substance.doseInfos, id: \.route) { doseInfo in
                Section(doseInfo.route.rawValue.localizedCapitalized) {
                    DoseRow(roaDose: doseInfo.roaDose)
                    if let bio = doseInfo.bioavailability?.displayString {
                        RowLabelView(label: "Bioavailability", value: "\(bio)%")
                    }
                }
            }
            if substance.name == "MDMA" {
                Section("Oral Max Dose Calculator") {
                    MDMAMaxDoseCalculator()
                }
                if #available(iOS 16, *) {
                    MDMAOptimalDoseSection()
                }
                MDMAPillsSection()
            }
            if let units = substance.roas.first?.dose?.units,
               let clarification = DosesScreen.getUnitClarification(for: units) {
                Section {
                    Text(clarification)
                }
            }
            Section("Disclaimer") {
                Text(ChooseDoseScreenContent.doseDisclaimer)
            }
        }
        .navigationTitle("Dosage")
        .headerProminence(.increased)
    }


    static func getUnitClarification(for units: String) -> String? {
        if units == "µg" {
            return "1 µg = 1/1000 mg = 1/1'000'000 gram"
        } else if units == "mg" {
            return "1 mg = 1/1000 gram"
        } else if units == "mL" {
            return "1 mL = 1/1000 L"
        } else {
            return nil
        }
    }
}

struct DosesScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DosesScreen(substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!)
            }
            NavigationView {
                DosesScreen(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
            }
        }
    }
}
