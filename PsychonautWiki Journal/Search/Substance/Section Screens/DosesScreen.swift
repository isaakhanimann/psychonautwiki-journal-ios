// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct DosesScreen: View {

    let substance: Substance
    
    var body: some View {
        List {
            if let remark = substance.dosageRemark {
                Section {
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
