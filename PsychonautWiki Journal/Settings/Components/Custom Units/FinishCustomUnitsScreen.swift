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
        case name
        case unit
        case dose
        case note
    }

    @State private var name = ""
    @State private var unit = ""
    @State private var dosePerUnit: Double?
    @State private var isEstimate = false
    @State private var isUnknownDose = false
    @State private var note = ""

    @FocusState private var focusedField: Field?

    private var roaDose: RoaDose? {
        substanceAndRoute.substance.getDose(for: substanceAndRoute.administrationRoute)
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .unit
                    }
                TextField("Unit", text: $unit, prompt: Text("e.g. pill, spray, etc."))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .unit)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .note
                    }
                TextField("Notes", text: $note)
                    .focused($focusedField, equals: .note)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .dose
                    }
            }
            Section("Dose per \(unitOrPlaceholder)") {
                RoaDoseRow(roaDose: roaDose)
                if !isUnknownDose {
                    HStack {
                        TextField(
                            "Dose per \(unitOrPlaceholder)",
                            value: $dosePerUnit,
                            format: .number
                        ).keyboardType(.decimalPad)
                            .focused($focusedField, equals: .dose)
                        Spacer()
                        Text(roaDose?.units ?? "")
                    }
                }
                Toggle("Estimated", isOn: $isEstimate.animation()).tint(.accentColor)
                Toggle("Unknown dose", isOn: $isUnknownDose).tint(.accentColor)
            }
        }
        .navigationTitle("Add Custom Unit")
        .onAppear {
            focusedField = .name
        }
        .optionalScrollDismissesKeyboard()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                DoneButton(action: onDoneTap)
                    .disabled(unit.isEmpty || name.isEmpty)
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
        newCustomUnit.name = name
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
            administrationRoute: .oral
        ),
        dismiss: {})
    }
}
