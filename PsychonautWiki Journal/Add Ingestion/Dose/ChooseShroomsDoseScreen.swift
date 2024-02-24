// Copyright (c) 2023. Isaak Hanimann.
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

struct ChooseShroomsDoseScreen: View {
    let dismiss: () -> Void
    let mushrooms = SubstanceRepo.shared.getSubstance(name: "Psilocybin mushrooms")!
    var oralDose: RoaDose {
        mushrooms.getDose(for: .oral)!
    }

    @State private var psilocybinTextInMg = ""
    @State private var psilocybinInMg: Double?
    @State private var psilocybinContentInPercentText = "1"
    @State private var psilocybinContentInPercent: Double? = 1.0
    @State private var isEstimate = false
    @State private var doseVariance: Double?
    @State private var shroomWeightText = ""
    @State private var shroomWeightInGrams: Double?

    private var suggestedNote: String? {
        if psilocybinContentInPercent != nil && shroomWeightInGrams != nil {
            return "\(shroomWeightText) grams of mushrooms with \(psilocybinContentInPercentText)% Psilocybin"
        } else {
            return nil
        }
    }

    private var currentDoseTypeColor: Color {
        guard let psilocybinInMg else { return .primary }
        return oralDose.getRangeType(for: psilocybinInMg, with: "mg").color
    }

    var body: some View {
        screen.toolbar {
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

    private var nextLink: some View {
        NavigationLink(value: FinishIngestionScreenArguments(
            substanceName: mushrooms.name,
            administrationRoute: .oral,
            dose: psilocybinInMg,
            units: "mg",
            isEstimate: isEstimate,
            estimatedDoseVariance: doseVariance,
            suggestedNote: suggestedNote
        )) {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Unknown Dose", value: FinishIngestionScreenArguments(
            substanceName: mushrooms.name,
            administrationRoute: .oral,
            dose: nil,
            units: "mg",
            isEstimate: false,
            estimatedDoseVariance: nil))
    }

    @FocusState private var isEstimatedVarianceFocused: Bool

    private var screen: some View {
        Form {
            Section("Ingested Psilocybin Amount") {
                RoaDoseRow(roaDose: oralDose)
                DynamicDoseRangeView(roaDose: oralDose, dose: psilocybinInMg)
                HStack {
                    TextField("Enter Dose", text: $psilocybinTextInMg)
                        .keyboardType(.decimalPad)
                        .foregroundColor(currentDoseTypeColor)
                        .onChange(of: psilocybinTextInMg) { text in
                            psilocybinInMg = getDouble(from: text)
                        }
                    Text("mg")
                }
                .font(.title)
                Toggle("Is Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                    .onChange(of: isEstimate, perform: { newIsEstimate in
                        if newIsEstimate {
                            isEstimatedVarianceFocused = true
                        }
                    })
                if isEstimate {
                    HStack {
                        Image(systemName: "plusminus")
                        TextField(
                            "Pure dose variance",
                            value: $doseVariance,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($isEstimatedVarianceFocused)
                        Spacer()
                        Text("mg")
                    }
                }
                unknownDoseLink
            }.listRowSeparator(.hidden)
            Section("Mushroom Psilocybin Calculation") {
                HStack {
                    TextField("Enter Mushroom Amount", text: $shroomWeightText)
                        .keyboardType(.decimalPad)
                        .onChange(of: shroomWeightText) { text in
                            shroomWeightInGrams = getDouble(from: text)
                            maybeUpdatePsilocybin()
                        }
                    Text("g")
                }.padding(.top, 5)
                HStack {
                    TextField("Enter Psilocybin Percentage", text: $psilocybinContentInPercentText)
                        .keyboardType(.decimalPad)
                        .onChange(of: psilocybinContentInPercentText) { text in
                            psilocybinContentInPercent = getDouble(from: text)
                            maybeUpdatePsilocybin()
                        }
                    Text("%")
                }
                Button("Dried Psilocybe cubensis ~1%") {
                    psilocybinContentInPercent = 1
                    psilocybinContentInPercentText = "1"
                }
                Button("Fresh Psilocybe cubensis ~0.1%") {
                    psilocybinContentInPercent = 0.1
                    psilocybinContentInPercentText = "0.1"
                }
            }.listRowSeparator(.hidden)
            if let remark = mushrooms.dosageRemark {
                Text(remark)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Psilocybin mushrooms")
    }

    func maybeUpdatePsilocybin() {
        if let psilocybinContentInPercent, let shroomWeightInGrams {
            let result = shroomWeightInGrams * 1000 * psilocybinContentInPercent / 100
            psilocybinInMg = result
            psilocybinTextInMg = result.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 1)
        }
    }
}

#Preview {
    NavigationStack {
        ChooseShroomsDoseScreen(dismiss: {})
    }
}
