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
    enum Field: Hashable {
        case name
        case unit
        case dose
        case note
        case estimatedDeviation
    }

    let substanceAndRoute: SubstanceAndRoute
    let dismiss: () -> Void

    var body: some View {
        Form {
            Section {
                TextField("Name to identify", text: $name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .unit
                    }
                TextField("Unit in singular form", text: $unit, prompt: Text("e.g. pill, spray, scoop etc."))
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
            let areUnitsDefined = roaDose?.units != nil
            if !areUnitsDefined {
                Section("Original Unit") {
                    UnitsPicker(units: $originalUnit)
                        .padding(.bottom, 10)
                }
            }
            Section("Dose per \(unitOrPlaceholder)") {
                if let roaDose {
                    RoaDoseRow(roaDose: roaDose)
                }
                if !isUnknownDose {
                    HStack {
                        TextField(
                            "Dose per \(unitOrPlaceholder)",
                            value: $dosePerUnit,
                            format: .number).keyboardType(.decimalPad)
                            .focused($focusedField, equals: .dose)
                        Spacer()
                        Text(originalUnit)
                    }
                }
                Toggle("Estimate", isOn: $isEstimate.animation())
                    .tint(.accentColor)
                    .onChange(of: isEstimate, perform: { newIsEstimate in
                        if newIsEstimate {
                            focusedField = .estimatedDeviation
                        }
                    })
                if isEstimate {
                    HStack {
                        Image(systemName: "plusminus")
                        TextField(
                            "Estimated standard deviation",
                            value: $estimatedDoseStandardDeviation,
                            format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .estimatedDeviation)
                        Spacer()
                        Text(originalUnit)
                    }
                }
                if let dosePerUnit, let estimatedDoseStandardDeviation {
                    StandardDeviationConfidenceIntervalExplanation(mean: dosePerUnit, standardDeviation: estimatedDoseStandardDeviation, unit: originalUnit)
                }
                Toggle("Unknown dose", isOn: $isUnknownDose).tint(.accentColor)
            }.listRowSeparator(.hidden)
            if let originalUnit = roaDose?.units, dosePerUnit != nil || isUnknownDose, !unit.isEmpty {
                Section("Ingestion Preview") {
                    VStack(alignment: .leading) {
                        Text("\(substanceAndRoute.substance.name), \(name)").font(.headline)
                        if isUnknownDose {
                            Text("\(multiplier.formatted()) \(unit) \(substanceAndRoute.administrationRoute.rawValue)")
                        } else {
                            if isEstimate {
                                if let calculatedDoseStandardDeviation {
                                    Text(multiplier.with(unit: unit)) +
                                        Text(
                                            " = \(calculatedDose?.asRoundedReadableString ?? "...")±\(calculatedDoseStandardDeviation.asRoundedReadableString) \(originalUnit) \(substanceAndRoute.administrationRoute.rawValue)")
                                        .foregroundColor(.secondary)
                                } else {
                                    Text(multiplier.with(unit: unit)) +
                                        Text(
                                            " = ~\(calculatedDose?.asRoundedReadableString ?? "...") \(originalUnit) \(substanceAndRoute.administrationRoute.rawValue)")
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text(multiplier.with(unit: unit)) +
                                    Text(
                                        " = \(calculatedDose?.asRoundedReadableString ?? "...") \(originalUnit) \(substanceAndRoute.administrationRoute.rawValue)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                if !isUnknownDose {
                    Section("Dose Picker Preview") {
                        VStack(alignment: .leading, spacing: 5) {
                            if !name.isEmpty {
                                Text(name).font(.headline)
                            }
                            CustomUnitDoseRow(
                                customUnit: CustomUnitMinInfo(dosePerUnit: dosePerUnit, unit: unit),
                                roaDose: roaDose)
                        }
                    }
                }
            }
        }
        .navigationTitle("Add Custom Unit")
        .onAppear {
            focusedField = .name
            originalUnit = roaDose?.units ?? "mg"
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                DoneButton(action: onDoneTap)
                    .disabled(unit.isEmpty || name.isEmpty)
            }
        }
    }

    @State private var name = ""
    @State private var unit = ""
    @State private var originalUnit = ""
    @State private var dosePerUnit: Double?
    @State private var isEstimate = false
    @State private var estimatedDoseStandardDeviation: Double?
    @State private var isUnknownDose = false
    @State private var note = ""

    @FocusState private var focusedField: Field?

    private let multiplier: Double = 3

    private var roaDose: RoaDose? {
        substanceAndRoute.substance.getDose(for: substanceAndRoute.administrationRoute)
    }

    private var unitOrPlaceholder: String {
        if unit.isEmpty {
            "..."
        } else {
            unit
        }
    }

    private var calculatedDose: Double? {
        guard let dosePerUnit else { return nil }
        return multiplier * dosePerUnit
    }

    private var calculatedDoseStandardDeviation: Double? {
        guard let estimatedDoseStandardDeviation else { return nil }
        return multiplier * estimatedDoseStandardDeviation
    }

    private func onDoneTap() {
        let context = PersistenceController.shared.viewContext
        let newCustomUnit = CustomUnit(context: context)
        newCustomUnit.name = name
        newCustomUnit.creationDate = Date()
        newCustomUnit.administrationRoute = substanceAndRoute.administrationRoute.rawValue
        newCustomUnit.dose = isUnknownDose ? 0 : (dosePerUnit ?? 0)
        newCustomUnit.note = note
        newCustomUnit.originalUnit = originalUnit
        newCustomUnit.substanceName = substanceAndRoute.substance.name
        newCustomUnit.unit = unit
        newCustomUnit.isEstimate = isEstimate
        newCustomUnit.estimatedDoseStandardDeviation = estimatedDoseStandardDeviation ?? 0
        newCustomUnit.isArchived = false
        newCustomUnit.idForAndroid = Int32.random(in: Int32.min..<Int32.max)
        try? context.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        FinishCustomUnitsScreen(
            substanceAndRoute: .init(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                administrationRoute: .oral),
            dismiss: { })
    }
}
