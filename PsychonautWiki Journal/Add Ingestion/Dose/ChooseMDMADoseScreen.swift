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
    @State private var mdmaDoseInMg: Double? = 113.0
    @State private var isEstimate = false
    private let units = "mg"
    @State private var doseText = "113"

    var body: some View {
        if #available(iOS 16, *) {
            screen.toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HideKeyboardButton()
                    nextLink
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Cancel") {
                        dismiss()
                    }
                    nextLink
                }
            }
        } else {
            screen.toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HideKeyboardButton()
                    nextLink
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
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
                dose: mdmaDoseInMg,
                units: units,
                isEstimate: isEstimate,
                dismiss: dismiss
            )
        } label: {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Use Unknown Dose") {
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
                MDMAMaxDoseCalculator { newMaxDose in
                    mdmaDoseInMg = newMaxDose
                    doseText = newMaxDose.formatted()
                }
            }
            Section("Choose Dose") {
                VStack(alignment: .leading, spacing: 5) {
                    DoseRow(roaDose: oralDose)
                    DynamicDoseRangeView(roaDose: oralDose, dose: mdmaDoseInMg)
                    HStack {
                        TextField("Enter Dose", text: $doseText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .foregroundColor(doseType.color)
                        Text(units)
                    }
                    .font(.title)
                    .onChange(of: doseText) { _ in
                        let formatter = NumberFormatter()
                        formatter.locale = Locale.current
                        formatter.numberStyle = .decimal
                        mdmaDoseInMg = formatter.number(from: doseText)?.doubleValue
                    }
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
                unknownDoseLink
            }
            if #available(iOS 16, *) {
                MDMAOptimalDoseSection()
            }
            MDMAPillsSection()
        }
        .optionalScrollDismissesKeyboard()
        .navigationTitle("MDMA Dosage")
    }

    var doseType: DoseRangeType {
        guard let mdmaDoseInMg else { return .none}
        return oralDose.getRangeType(for: mdmaDoseInMg, with: units)
    }
}

struct ChooseMDMADoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseMDMADoseScreen(dismiss: {})
        }
    }
}
