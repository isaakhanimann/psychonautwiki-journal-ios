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

struct EditCustomUnitsScreen: View {
    let customUnit: CustomUnit

    @State private var name: String = ""
    @State private var originalUnit: String?
    @State private var unit: String = ""
    @State private var note: String = ""
    @State private var dose: Double?
    @State private var isEstimate: Bool = false
    @State private var isArchived: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditCustomUnitsScreenContent(
            substanceName: customUnit.substanceNameUnwrapped,
            roaDose: customUnit.substance?.getDose(for: customUnit.administrationRouteUnwrapped),
            name: $name,
            originalUnit: $originalUnit,
            unit: $unit,
            note: $note,
            dose: $dose,
            isEstimate: $isEstimate,
            isArchived: $isArchived,
            delete: delete
        )
        .onAppear {
            name = customUnit.nameUnwrapped
            originalUnit = customUnit.originalUnit
            unit = customUnit.unitUnwrapped
            note = customUnit.noteUnwrapped
            dose = customUnit.doseUnwrapped
            isEstimate = customUnit.isEstimate
            isArchived = customUnit.isArchived
        }
        .onDisappear {
            save()
        }
    }

    private func save() {
        customUnit.name = name
        customUnit.originalUnit = originalUnit
        customUnit.unit = unit
        customUnit.note = note
        customUnit.dose = dose ?? 0
        customUnit.isEstimate = isEstimate
        customUnit.isArchived = isArchived
        PersistenceController.shared.saveViewContext()
        dismiss()
    }

    private func delete() {
        PersistenceController.shared.viewContext.delete(customUnit)
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}

struct EditCustomUnitsScreenContent: View {
    let substanceName: String
    let roaDose: RoaDose?
    @Binding var name: String
    @Binding var originalUnit: String?
    @Binding var unit: String
    @Binding var note: String
    @Binding var dose: Double?
    @Binding var isEstimate: Bool
    @Binding var isArchived: Bool
    let delete: () -> Void

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .autocapitalization(.sentences)
                TextField("Unit", text: $unit).autocorrectionDisabled().textInputAutocapitalization(.never)
                TextField("Enter Note", text: $note)
                    .autocapitalization(.sentences)
                Toggle("Archive", isOn: $isArchived).tint(.accentColor)
            }
            Section {
                RoaDoseRow(roaDose: roaDose)
                DosePicker(
                    roaDose: roaDose,
                    doseMaybe: $dose,
                    selectedUnits: $originalUnit
                )
                Toggle("Is an Estimate", isOn: $isEstimate).tint(.accentColor)
            }.listRowSeparator(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: delete) {
                    Label("Delete Unit", systemImage: "trash")
                }
            }
        }
        .optionalScrollDismissesKeyboard()
        .navigationTitle("Edit Unit")
    }
}

#Preview {
    NavigationStack {
        EditCustomUnitsScreenContent(
            substanceName: "MDMA",
            roaDose: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDose(for: .oral)!,
            name: .constant("pink rocket"),
            originalUnit: .constant("mg"),
            unit: .constant("pill"),
            note: .constant("These are my notes"),
            dose: .constant(50),
            isEstimate: .constant(false),
            isArchived: .constant(false),
            delete: {}
        )
    }
}
