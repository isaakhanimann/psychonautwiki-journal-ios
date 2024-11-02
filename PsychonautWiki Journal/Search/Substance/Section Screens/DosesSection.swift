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

struct DosesSection: View {
    init(substance: Substance) {
        self.substance = substance
        customUnits = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \CustomUnit.creationDate, ascending: false)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "isArchived == %@", NSNumber(value: false)),
                NSPredicate(format: "substanceName == %@", substance.name),
            ]))
    }

    let substance: Substance

    @State private var isDisclaimerShown = false

    var body: some View {
        Group {
            Section {
                if let remark = substance.dosageRemark {
                    Text(remark)
                }
                ForEach(substance.doseInfos, id: \.route) { doseInfo in
                    VStack(alignment: .leading,spacing: 8, content: {
                        Text(doseInfo.route.rawValue.localizedCapitalized).font(.headline)
                        RoaDoseRow(roaDose: doseInfo.roaDose)
                        let customUnitsForRoa = customUnits.wrappedValue.filter { customUnit in
                            customUnit.administrationRouteUnwrapped == doseInfo.route && customUnit.doseUnwrapped != nil
                        }
                        ForEach(customUnitsForRoa) { customUnit in
                            Text(customUnit.nameUnwrapped).font(.headline)
                            CustomUnitDoseRow(customUnit: customUnit.minInfo, roaDose: doseInfo.roaDose)
                        }
                        if let bio = doseInfo.bioavailability?.displayString {
                            RowLabelView(label: "Bioavailability", value: "\(bio)%")
                        }
                    })
                }
            } header: {
                HStack {
                    Text("Dose")
                    Spacer()
                    Button("Disclaimer") {
                        isDisclaimerShown = true
                    }
                }
            }
            .alert(
                "Dosage Disclaimer",
                isPresented: $isDisclaimerShown) {
                    Button("Ok") {
                        isDisclaimerShown = false
                    }
                } message: {
                    Text(ChooseDoseScreenContent.doseDisclaimer)
                }

            if substance.name == "MDMA" {
                Section("Oral Max Dose Calculator") {
                    MDMAMaxDoseCalculator(onChangeOfMax: { _ in })
                }
                MDMAOptimalDoseSection()
                MDMAPillsSection()
            }
            if substance.roas.contains(where: { $0.name == .smoked }), substance.categories.contains("opioid") {
                ChasingTheDragonSection()
            }
        }
    }

    static func getUnitClarification(for units: String) -> String? {
        if units == "µg" {
            "1 µg = 1/1000 mg = 1/1'000'000 gram"
        } else if units == "mg" {
            "1 mg = 1/1000 gram"
        } else if units == "mL" {
            "1 mL = 1/1000 L"
        } else {
            nil
        }
    }

    private var customUnits: FetchRequest<CustomUnit>

}

#Preview {
    List {
        DosesSection(substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!)
    }
}

#Preview {
    List {
        DosesSection(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
    }
}
