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

struct FinishCustomUnitsScreen: View {

    let substanceAndRoute: SubstanceAndRoute
    let dismiss: () -> Void

    enum Field: Hashable {
        case unit
        case dose
        case note
    }

    @State private var unit = ""
    @State private var dosePerUnit: Double? = nil
    @State private var isEstimate = false
    @State private var isUnknownDose = false
    @State private var note = ""

    @FocusState private var focusedField: Field?

    private var roaDose: RoaDose? {
        substanceAndRoute.substance.getDose(for: substanceAndRoute.administrationRoute)
    }

    var body: some View {
        Form {
            TextField("Unit name", text: $unit).autocorrectionDisabled().textInputAutocapitalization(.never)
                .focused($focusedField, equals: .unit)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .dose
                }
            Section("1 \(unitOrPlaceholder) = ") {
                DoseRow(roaDose: roaDose)
                if !isUnknownDose {
                    HStack {
                        TextField("Dose per \(unitOrPlaceholder)", value: $dosePerUnit, format: .number).keyboardType(.decimalPad)
                            .focused($focusedField, equals: .dose)
                        Spacer()
                        Text(roaDose?.units ?? "")
                    }
                }
                Toggle("Estimated", isOn: $isEstimate.animation()).tint(.accentColor)
                Toggle("Unknown dose", isOn: $isUnknownDose).tint(.accentColor)
                TextField("Notes", text: $note)
                    .focused($focusedField, equals: .note)
                    .submitLabel(.done)
                    .onSubmit(onDoneTap)
            }

        }
        .navigationTitle("Add Custom Unit")
        .onAppear {
            focusedField = .unit
        }
        .optionalScrollDismissesKeyboard()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                DoneButton(action: onDoneTap)
                    .disabled(unit.isEmpty)
            }
        }
    }

    private var unitOrPlaceholder: String {
        if unit.isEmpty {
            return "..."
        } else {
            return unit
        }
    }

    private func onDoneTap() {
        let context = PersistenceController.shared.viewContext
        let newCustomUnit = CustomUnit(context: context)
        newCustomUnit.creationDate = Date()
        newCustomUnit.administrationRoute = substanceAndRoute.administrationRoute.rawValue
        newCustomUnit.dose = isUnknownDose ? 0 : (dosePerUnit ?? 0)
        newCustomUnit.note = note
        newCustomUnit.originalUnit = roaDose?.units
        newCustomUnit.substanceName = substanceAndRoute.substance.name
        newCustomUnit.unit = unit
        newCustomUnit.isEstimate = isEstimate
        try? context.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        FinishCustomUnitsScreen(substanceAndRoute: .init(
            substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
            administrationRoute: .oral),
                                dismiss: {})
    }
}
