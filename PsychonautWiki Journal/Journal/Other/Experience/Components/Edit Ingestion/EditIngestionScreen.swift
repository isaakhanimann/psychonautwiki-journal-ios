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
    let isEyeOpen: Bool
    @State private var time = Date()
    @State private var dose: Double?
    @State private var customUnitDose: Double?
    @State private var units: String? = "mg"
    @State private var isEstimate = false
    @State private var note = ""
    @State private var consumerName = ""
    @State private var stomachFullness = StomachFullness.empty
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditIngestionContent(
            substanceName: ingestion.substanceNameUnwrapped,
            roaDose: ingestion.substance?.getDose(for: ingestion.administrationRouteUnwrapped),
            customUnit: ingestion.customUnit,
            route: ingestion.administrationRouteUnwrapped,
            time: $time,
            dose: $dose,
            customUnitDose: $customUnitDose,
            units: $units,
            isEstimate: $isEstimate,
            note: $note,
            stomachFullness: $stomachFullness,
            consumerName: $consumerName,
            save: save,
            delete: delete,
            isEyeOpen: isEyeOpen)
            .onAppear {
                time = ingestion.timeUnwrapped
                dose = ingestion.doseUnwrapped
                customUnitDose = ingestion.customUnitDoseUnwrapped
                units = ingestion.units
                isEstimate = ingestion.isEstimate
                note = ingestion.noteUnwrapped
                consumerName = ingestion.consumerName ?? ""
                if let fullness = ingestion.stomachFullnessUnwrapped {
                    stomachFullness = fullness
                }
            }
    }

    private func save() {
        ingestion.time = time
        ingestion.dose = dose ?? 0
        ingestion.customUnitDose = customUnitDose ?? 0
        ingestion.units = units
        ingestion.isEstimate = isEstimate
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
    let customUnit: CustomUnit?
    let route: AdministrationRoute
    @Binding var time: Date
    @Binding var dose: Double?
    @Binding var customUnitDose: Double?
    @Binding var units: String?
    @Binding var isEstimate: Bool
    @Binding var note: String
    @Binding var stomachFullness: StomachFullness
    @Binding var consumerName: String
    let save: () -> Void
    let delete: () -> Void
    let isEyeOpen: Bool

    var body: some View {
        Form {
            Section("\(route.rawValue.localizedCapitalized) Dose") {
                RoaDoseRow(roaDose: roaDose)
                if let customUnit {
                    CustomUnitDosePicker(
                        customUnit: customUnit,
                        isDoseEstimated: isEstimate,
                        dose: $customUnitDose)
                } else {
                    DosePicker(
                        roaDose: roaDose,
                        doseMaybe: $dose,
                        selectedUnits: $units)
                }
                Toggle("Is an Estimate", isOn: $isEstimate).tint(.accentColor)
            }.listRowSeparator(.hidden)
            Section("Notes") {
                TextField("Enter Note", text: $note)
                    .autocapitalization(.sentences)
            }
            Section("Ingestion Time") {
                DatePicker(
                    "Enter Ingestion Time",
                    selection: $time,
                    displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(.wheel)
            }
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
                EditStomachFullnessSection(stomachFullness: $stomachFullness)
            }
        }
        .sheet(isPresented: $isConsumerSheetPresented, content: {
            EditConsumerScreen(consumerName: $consumerName)
        })
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: delete) {
                    Label("Delete Ingestion", systemImage: "trash")
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit \(substanceName)")
        .onDisappear {
            save()
        }
    }

    @State private var isConsumerSheetPresented = false

    private var isConsumerMe: Bool {
        consumerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

}

#Preview("Edit regular ingestion") {
    NavigationStack {
        EditIngestionContent(
            substanceName: "MDMA",
            roaDose: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDose(for: .oral)!,
            customUnit: nil,
            route: .oral,
            time: .constant(Date()),
            dose: .constant(50),
            customUnitDose: .constant(nil),
            units: .constant("mg"),
            isEstimate: .constant(false),
            note: .constant("These are my notes"),
            stomachFullness: .constant(.full),
            consumerName: .constant("Marc"),
            save: { },
            delete: { },
            isEyeOpen: true)
    }
}

#Preview("Edit custom unit ingestion") {
    NavigationStack {
        EditIngestionContent(
            substanceName: "Ketamine",
            roaDose: SubstanceRepo.shared.getSubstance(name: "Ketamine")!.getDose(for: .oral)!,
            customUnit: CustomUnit.previewSample,
            route: .oral,
            time: .constant(Date()),
            dose: .constant(nil),
            customUnitDose: .constant(2),
            units: .constant("mg"),
            isEstimate: .constant(false),
            note: .constant("These are my notes"),
            stomachFullness: .constant(.full),
            consumerName: .constant("Marc"),
            save: { },
            delete: { },
            isEyeOpen: true)
    }
}

