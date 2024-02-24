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

// MARK: - EditIngestionScreen

struct EditIngestionScreen: View {
    let ingestion: Ingestion
    @State private var time = Date()
    @State private var dose: Double?
    @State private var units: String = "mg"
    @State private var isEstimate = false
    @State private var estimatedDoseVariance: Double?
    @State private var note = ""
    @State private var consumerName = ""
    @State private var stomachFullness = StomachFullness.empty
    @State private var selectedCustomUnit: CustomUnit? = nil

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    @Environment(\.dismiss) var dismiss

    @FetchRequest(
        sortDescriptors: []
    ) var customUnits: FetchedResults<CustomUnit>

    private var filteredCustomUnit: [CustomUnit] {
        customUnits.filter { unit in
            unit.substanceNameUnwrapped == ingestion.substanceNameUnwrapped && unit.administrationRouteUnwrapped == ingestion.administrationRouteUnwrapped && !unit.isArchived
        }
    }

    private var roaDose: RoaDose? {
        ingestion.substance?.getDose(for: ingestion.administrationRouteUnwrapped)
    }

    var body: some View {
        EditIngestionContent(
            substanceName: ingestion.substanceNameUnwrapped,
            roaDose: roaDose,
            customUnit: $selectedCustomUnit,
            otherUnits: filteredCustomUnit,
            route: ingestion.administrationRouteUnwrapped,
            time: $time,
            dose: $dose,
            units: $units,
            isEstimate: $isEstimate,
            estimatedDoseVariance: $estimatedDoseVariance,
            note: $note,
            stomachFullness: $stomachFullness,
            consumerName: $consumerName,
            save: save,
            delete: delete,
            isEyeOpen: isEyeOpen
        ).onFirstAppear {
            time = ingestion.timeUnwrapped
            dose = ingestion.doseUnwrapped
            units = ingestion.unitsUnwrapped
            isEstimate = ingestion.isEstimate
            estimatedDoseVariance = ingestion.estimatedDoseVarianceUnwrapped
            note = ingestion.noteUnwrapped
            consumerName = ingestion.consumerName ?? ""
            selectedCustomUnit = ingestion.customUnit
            if let fullness = ingestion.stomachFullnessUnwrapped {
                stomachFullness = fullness
            }
        }
    }

    private func save() {
        ingestion.time = time
        ingestion.dose = dose ?? 0
        if let selectedCustomUnit {
            ingestion.customUnit?.removeFromIngestions(ingestion)
            ingestion.customUnit = selectedCustomUnit
            ingestion.units = selectedCustomUnit.unitUnwrapped
        } else {
            ingestion.units = roaDose?.units ?? units
            ingestion.customUnit?.removeFromIngestions(ingestion)
        }
        ingestion.isEstimate = isEstimate
        ingestion.estimatedDoseVariance = estimatedDoseVariance ?? 0
        ingestion.note = note
        if consumerName.trimmingCharacters(in: .whitespaces).isEmpty {
            ingestion.consumerName = nil
        } else {
            ingestion.consumerName = consumerName
        }
        if ingestion.administrationRouteUnwrapped == .oral {
            ingestion.stomachFullness = stomachFullness.rawValue
        }
        PersistenceController.shared.saveViewContext()
        ingestion.experience?.objectWillChange.send()
        dismiss()
    }

    private func delete() {
        PersistenceController.shared.viewContext.delete(ingestion)
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}

// MARK: - EditIngestionContent

struct EditIngestionContent: View {
    let substanceName: String
    let roaDose: RoaDose?
    @Binding var customUnit: CustomUnit?
    let otherUnits: [CustomUnit]
    let route: AdministrationRoute
    @Binding var time: Date
    @Binding var dose: Double?
    @Binding var units: String
    @Binding var isEstimate: Bool
    @Binding var estimatedDoseVariance: Double?
    @Binding var note: String
    @Binding var stomachFullness: StomachFullness
    @Binding var consumerName: String
    let save: () -> Void
    let delete: () -> Void
    let isEyeOpen: Bool

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("\(route.rawValue.localizedCapitalized) Dose") {
                    VStack(alignment: .leading, spacing: 8) {
                        if let roaDose {
                            RoaDoseRow(roaDose: roaDose)
                        }
                        if let customUnit {
                            CustomUnitCalculationText(
                                customUnit: customUnit,
                                dose: dose,
                                isEstimate: isEstimate,
                                estimatedDoseVariance: estimatedDoseVariance)
                        } else {
                            DosePicker(
                                roaDose: roaDose,
                                doseMaybe: $dose,
                                selectedUnits: $units)
                            Toggle("Is an Estimate", isOn: $isEstimate)
                                .tint(.accentColor)
                            if isEstimate {
                                HStack {
                                    Image(systemName: "plusminus")
                                    TextField(
                                        "Dose variance",
                                        value: $estimatedDoseVariance,
                                        format: .number
                                    )
                                    .keyboardType(.decimalPad)
                                    Spacer()
                                    Text(units)
                                }
                            }
                        }
                    }
                    if !otherUnits.isEmpty {
                        NavigationLink {
                            ChooseCustomUnitScreen(customUnit: $customUnit, customUnits: otherUnits)
                        } label: {
                            HStack {
                                Text("Choose Unit")
                                Spacer()
                                Group {
                                    if let customUnit {
                                        Text(customUnit.nameUnwrapped)
                                    } else {
                                        Text("Default")
                                    }
                                }.foregroundStyle(.secondary)
                            }
                        }
                        .onChange(of: customUnit, perform: { unit in
                            units = unit?.unit ?? roaDose?.units ?? ""
                        })
                    }
                }.listRowSeparator(.hidden)
                if let customUnit {
                    Section(customUnit.nameUnwrapped) {
                        CustomUnitDosePicker(
                            customUnit: customUnit,
                            dose: $dose,
                            isEstimate: $isEstimate,
                            estimatedDoseVariance: $estimatedDoseVariance)
                    }.listRowSeparator(.hidden)
                }
                Section("Notes") {
                    TextField("Enter Note", text: $note)
                        .autocapitalization(.sentences)
                }
                Section {
                    DatePicker(
                        "Time",
                        selection: $time,
                        displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    HStack {
                        Text("Consumer")
                        Spacer()
                        Button {
                            isConsumerSheetPresented.toggle()
                        } label: {
                            let displayedName = isConsumerMe ? "Me" : consumerName
                            Label(displayedName, systemImage: "person")
                        }
                    }
                    if route == .oral, isEyeOpen {
                        StomachFullnessPicker(stomachFullness: $stomachFullness)
                            .pickerStyle(.menu)
                    }
                }.listRowSeparator(.hidden)
                Section {
                    Button(action: delete) {
                        Label("Delete Ingestion", systemImage: "trash").foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $isConsumerSheetPresented, content: {
                EditConsumerScreen(consumerName: $consumerName)
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save, label: {
                        Text("Save")
                    })
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {dismiss()}, label: {
                        Text("Cancel")
                    })
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Ingestion")
        }
    }

    @State private var isConsumerSheetPresented = false

    private var isConsumerMe: Bool {
        consumerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

}

#Preview("Edit regular ingestion") {
    EditIngestionContent(
        substanceName: "MDMA",
        roaDose: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDose(for: .oral)!,
        customUnit: .constant(nil),
        otherUnits: [
            CustomUnit.previewSample
        ],
        route: .oral,
        time: .constant(Date()),
        dose: .constant(50),
        units: .constant("mg"),
        isEstimate: .constant(false),
        estimatedDoseVariance: .constant(nil),
        note: .constant("These are my notes"),
        stomachFullness: .constant(.full),
        consumerName: .constant("Marc"),
        save: { },
        delete: { },
        isEyeOpen: true)
}

#Preview("Edit custom unit ingestion") {
    EditIngestionContent(
        substanceName: "Ketamine",
        roaDose: SubstanceRepo.shared.getSubstance(name: "Ketamine")!.getDose(for: .oral)!,
        customUnit: .constant(CustomUnit.previewSample),
        otherUnits: [],
        route: .oral,
        time: .constant(Date()),
        dose: .constant(2),
        units: .constant("mg"),
        isEstimate: .constant(false),
        estimatedDoseVariance: .constant(nil),
        note: .constant("These are my notes"),
        stomachFullness: .constant(.full),
        consumerName: .constant("Marc"),
        save: { },
        delete: { },
        isEyeOpen: true)
}

