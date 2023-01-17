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

struct ChooseMDMADoseScreen: View {
    let dismiss: () -> Void
    private let mdma = SubstanceRepo.shared.getSubstance(name: "MDMA")!
    private var oralDose: RoaDose {
        mdma.getDose(for: .oral)!
    }
    @State private var mdmaDoseInMg = 100.0
    @State private var isEstimate = false
    private let units = "mg"
    private var doseRounded: Double {
        round(mdmaDoseInMg)
    }
    private var doseText: String {
        String(Int(doseRounded))
    }

    var body: some View {
        if #available(iOS 16, *) {
            screen.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    unknownDoseLink
                    nextLink
                }
            }
        } else {
            screen.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    nextLink
                }
            }
        }
    }

    private var nextLink: some View {
        NavigationLink {
            FinishIngestionScreen(
                substanceName: mdma.name,
                administrationRoute: .oral,
                dose: doseRounded,
                units: units,
                isEstimate: isEstimate,
                dismiss: dismiss
            )
        } label: {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Unknown Dose") {
            FinishIngestionScreen(
                substanceName: mdma.name,
                administrationRoute: .oral,
                dose: nil,
                units: units,
                isEstimate: false,
                dismiss: dismiss
            )
        }
    }

    private var screen: some View {
        Form {
            Section("Max Dose Calculator") {
                MDMAMaxDoseCalculator()
            }
            Section("Choose Dose") {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: mdmaDoseInMg, with: units)
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: oralDose)
                    Slider(
                        value: $mdmaDoseInMg,
                        in: 10...400,
                        step: 10
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("400")
                    }
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
            }
            if #available(iOS 16, *) {
                MDMAOptimalDoseSection()
            } else {
                unknownDoseLink
            }
            MDMAPillsSection()
        }
        .navigationTitle("MDMA Dosage")
    }
}

struct ChooseMDMADoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseMDMADoseScreen(dismiss: {})
        }
    }
}
