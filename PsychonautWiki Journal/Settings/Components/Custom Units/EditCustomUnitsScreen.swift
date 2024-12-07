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
    @State private var originalUnit = ""
    @State private var unit: String = ""
    @State private var note: String = ""
    @State private var dose: Double?
    @State private var isEstimate: Bool = false
    @State private var estimatedDoseStandardDeviation: Double?
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
            estimatedDoseStandardDeviation: $estimatedDoseStandardDeviation,
            isArchived: $isArchived,
            delete: delete,
            ingestionCount: customUnit.ingestionsUnwrapped.count
        )
        .onAppear {
            name = customUnit.nameUnwrapped
            originalUnit = customUnit.originalUnitUnwrapped
            unit = customUnit.unitUnwrapped
            note = customUnit.noteUnwrapped
            dose = customUnit.doseUnwrapped
            isEstimate = customUnit.isEstimate
            estimatedDoseStandardDeviation = customUnit.estimatedDoseStandardDeviationUnwrapped
            isArchived = customUnit.isArchived
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
            }
        }
    }

    private func save() {
        customUnit.name = name
        customUnit.originalUnit = originalUnit
        customUnit.unit = unit
        customUnit.note = note
        customUnit.dose = dose ?? 0
        customUnit.isEstimate = isEstimate
        customUnit.estimatedDoseStandardDeviation = estimatedDoseStandardDeviation ?? 0
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
    @Binding var originalUnit: String
    @Binding var unit: String
    @Binding var note: String
    @Binding var dose: Double?
    @Binding var isEstimate: Bool
    @Binding var estimatedDoseStandardDeviation: Double?
    @Binding var isArchived: Bool
    let delete: () -> Void
    let ingestionCount: Int

    @State private var isDeleteShown = false

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .autocorrectionDisabled().textInputAutocapitalization(.never)
                TextField("Unit", text: $unit).autocorrectionDisabled().textInputAutocapitalization(.never)
                TextField("Enter Note", text: $note)
                    .autocapitalization(.sentences)
            }
            Section {
                if let roaDose {
                    RoaDoseRow(roaDose: roaDose)
                }
                DosePicker(
                    roaDose: roaDose,
                    doseMaybe: $dose,
                    selectedUnits: $originalUnit
                )
                Toggle("Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                if isEstimate {
                    HStack {
                        Image(systemName: "plusminus")
                        TextField(
                            "Estimated standard deviation",
                            value: $estimatedDoseStandardDeviation,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        Spacer()
                        Text(originalUnit)
                    }
                }
            }.listRowSeparator(.hidden)

            Section {
                Toggle("Archive", isOn: $isArchived).tint(.accentColor)
            } footer: {
                Text("Archived custom units don't show up when adding ingestions")
            }

            Section {
                Button {
                    if ingestionCount > 0 {
                        isDeleteShown.toggle()
                    } else {
                        delete()
                    }
                } label: {
                    Label("Delete Unit", systemImage: "trash").foregroundColor(.red)
                }
            }
        }
        .alert("Are you sure?", isPresented: $isDeleteShown, actions: {
            Button(role: .destructive) {
                delete()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }
        }, message: {
            Text("Deleting this unit will delete \(ingestionCount.with(pluralizableUnit: PluralizableUnit(singular: "ingestion", plural: "ingestions"))) that are using it. If you don't want to use it anymore archive it instead.")
        })
        .scrollDismissesKeyboard(.interactively)
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
            estimatedDoseStandardDeviation: .constant(nil),
            isArchived: .constant(false),
            delete: {},
            ingestionCount: 4
        )
    }
}
