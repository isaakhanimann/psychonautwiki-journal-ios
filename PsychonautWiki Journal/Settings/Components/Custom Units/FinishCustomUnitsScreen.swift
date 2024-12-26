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

enum CustomUnitArguments: Hashable {
    case substance(substance: Substance, administrationRoute: AdministrationRoute)
    case customSubstance(customSubstanceName: String, administrationRoute: AdministrationRoute, customSubstanceUnit: String)

    var substanceName: String {
        switch self {
        case .substance(let substance, _):
            return substance.name
        case .customSubstance(let customSubstanceName, _, _):
            return customSubstanceName
        }
    }

    var administrationRoute: AdministrationRoute {
        switch self {
        case .substance(_, let administrationRoute):
            return administrationRoute
        case .customSubstance( _, let administrationRoute, _):
            return administrationRoute
        }
    }
}

struct FinishCustomUnitsScreen: View {
    enum Field: Hashable {
        case name
        case unit
        case unitPlural
        case dose
        case note
        case estimatedDeviation
    }

    let arguments: CustomUnitArguments
    let cancel: () -> Void
    let onAdded: (CustomUnit) -> Void

    struct Prompt {
        let name: String
        let unit: String
        let unitPlural: String
    }

    var prompt: Prompt {
        switch arguments.substanceName {
        case "Cannabis":
            return Prompt(name: "e.g. Joint weed 20%, Bong weed, Vaporizer weed", unit: "mg", unitPlural: "mg")
        case "Psilocybin mushrooms":
            return Prompt(name: "Mushroom strain", unit: "g", unitPlural: "g")
        case "Alcohol":
            return Prompt(name: "e.g. Beer, Wine, Spirit", unit: "e.g. ml, cup", unitPlural: "e.g. ml, cups")
        case "Caffeine":
            return Prompt(name: "e.g. Coffee, Tea, Energy drink", unit: "e.g. cup, can", unitPlural: "e.g. cups, cans")
        default:
            switch arguments.administrationRoute {
            case .oral:
                return Prompt(name: "e.g. Blue rocket, 85% powder", unit: "e.g. pill, capsule, mg", unitPlural: "e.g. pills, capsules, mg")
            case .smoked:
                return Prompt(name: "e.g. 85% powder", unit: "e.g. mg, hit", unitPlural: "e.g. mg, hits")
            case .insufflated:
                return Prompt(name: "e.g. Nasal solution, Blue dispenser", unit: "e.g. spray, spoon, scoop, line", unitPlural: "e.g. sprays, spoons, scoops, lines")
            case .buccal:
                return Prompt(name: "e.g. Brand name", unit: "e.g. pouch", unitPlural: "e.g. pouches")
            case .transdermal:
                return Prompt(name: "e.g. Brand name", unit: "e.g. patch", unitPlural: "e.g. patches")
            default:
                return Prompt(name: "e.g. 85% powder, Blue rocket", unit: "e.g. pill, spray, spoon", unitPlural: "e.g. pills, sprays, spoons")
            }

        }
    }
    
    var body: some View {
        let substanceName = arguments.substanceName
        Form {
            if substanceName == "Cannabis" && arguments.administrationRoute == .smoked {
                Section {
                    Text("When smoking a joint about 23% of the THC in the bud is inhaled. So if you smoke a joint with 300mg of a bud that has 20% THC then you inhale 300mg * 20/100 * 23/100 = 13.8mg THC.")
                    Text("When smoking with a bong about 40% of the THC in the bud is inhaled. So if you smoke 300mg of a bud that has 20% THC then you inhale 300mg * 20/100 * 40/100 = 24mg THC.")
                    Text("When smoking with a vaporizer about 70% of the THC in the bud is inhaled. So if you smoke 300mg of a bud that has 20% THC then you inhale 300mg * 20/100 * 70/100 = 42mg THC.")
                }
            } else if substanceName == "Psilocybin mushrooms" {
                Section {
                    Text("Dried Psilocybe cubensis contain around 1% of Psilocybin.")
                    Text("Fresh Psilocybe cubensis contain around 0.1% of Psilocybin.")
                    Text("Research the strain of mushroom you have to be able to estimate the amount of Psilocybin it contains.")
                }
            } else if substanceName == "Alcohol" {
                Section {
                    Text("1 ml of Ethanol is 0.8g. So if you are e.g. consuming 200ml of a spirit with 40% of Alcohol you are consuming 200ml * 40/100 * 0.8 = 64g Ethanol.")
                }
            }
            Section {
                LabeledContent {
                    TextField("Name", text: $name, prompt: Text(prompt.name))
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .unit
                        }
                } label: {
                    Text("Name:")
                }
                LabeledContent {
                    TextField("Unit", text: $unit, prompt: Text(prompt.unit))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .unit)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .unitPlural
                        }
                } label: {
                    Text("Unit singular:")
                }
                .onChange(of: unit, perform: { newValue in
                    if !newValue.hasSuffix("s") && newValue != "mg" && newValue != "g" && newValue.lowercased() != "ml" {
                        unitPlural = newValue + "s"
                    } else {
                        unitPlural = newValue
                    }
                })
                LabeledContent {
                    TextField("Unit plural", text: $unitPlural, prompt: Text(prompt.unitPlural))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .unitPlural)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .note
                        }
                } label: {
                    Text("Unit plural:")
                }
                TextField("Notes", text: $note, axis: .vertical)
                    .focused($focusedField, equals: .note)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .dose
                    }
            }
            let areUnitsDefined = roaDose?.units != nil
            if case .substance = arguments, !areUnitsDefined  {
                Section("Original Unit") {
                    UnitsPicker(units: $originalUnit)
                        .padding(.bottom, 10)
                }
            }
            Section("Dose per \(unitOrPlaceholder)") {
                if let roaDose {
                    RoaDoseRow(roaDose: roaDose)
                }
                HStack {
                    TextField(
                        "Dose per \(unitOrPlaceholder)",
                        value: $dosePerUnit,
                        format: .number).keyboardType(.decimalPad)
                        .focused($focusedField, equals: .dose)
                    Spacer()
                    Text(originalUnit)
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
                    if let dosePerUnit, let estimatedDoseStandardDeviation {
                        StandardDeviationConfidenceIntervalExplanation(mean: dosePerUnit, standardDeviation: estimatedDoseStandardDeviation, unit: originalUnit)
                    }
                }
            }.listRowSeparator(.hidden)
            let isUnknownDosePerUnit = dosePerUnit == nil
            if let originalUnit = roaDose?.units, !unit.isEmpty {
                Section("Ingestion Preview") {
                    IngestionRowPreview(
                        substanceName: substanceName,
                        administrationRoute: arguments.administrationRoute,
                        multiplier: 3,
                        isEstimate: isEstimate,
                        isUnknownDosePerUnit: isUnknownDosePerUnit,
                        unit: unit,
                        unitPlural: unitPlural,
                        calculatedDose: calculatedDose,
                        calculatedDoseStandardDeviation: calculatedDoseStandardDeviation,
                        originalUnit: originalUnit,
                        name: name)
                }
                if !isUnknownDosePerUnit {
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
            switch arguments {
            case .substance(_, _):
                originalUnit = roaDose?.units ?? "mg"
            case .customSubstance(_, _, let customSubstanceUnit):
                originalUnit = customSubstanceUnit
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: cancel)
            }
            ToolbarItem(placement: .primaryAction) {
                DoneButton(action: onDoneTap)
                    .disabled(unit.isEmpty || name.isEmpty)
            }
        }
    }

    @State private var name = ""
    @State private var unit = ""
    @State private var unitPlural = ""
    @State private var originalUnit = ""
    @State private var dosePerUnit: Double?
    @State private var isEstimate = false
    @State private var estimatedDoseStandardDeviation: Double?
    @State private var note = ""

    @FocusState private var focusedField: Field?

    private let multiplier: Double = 3

    private var roaDose: RoaDose? {
        switch arguments {
        case .substance(let substance, let administrationRoute):
            return substance.getDose(for: administrationRoute)
        case .customSubstance(_, _, _):
            return nil
        }
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
        newCustomUnit.administrationRoute = arguments.administrationRoute.rawValue
        newCustomUnit.dose = dosePerUnit ?? 0
        newCustomUnit.note = note
        newCustomUnit.originalUnit = originalUnit
        newCustomUnit.substanceName = arguments.substanceName
        newCustomUnit.unit = unit
        newCustomUnit.unitPlural = unitPlural
        newCustomUnit.isEstimate = isEstimate
        newCustomUnit.estimatedDoseStandardDeviation = estimatedDoseStandardDeviation ?? 0
        newCustomUnit.isArchived = false
        newCustomUnit.idForAndroid = Int32.random(in: Int32.min..<Int32.max)
        try? context.save()
        onAdded(newCustomUnit)
    }
}

struct IngestionRowPreview: View {

    let substanceName: String
    let administrationRoute: AdministrationRoute
    let multiplier: Double
    let isEstimate: Bool
    let isUnknownDosePerUnit: Bool
    let unit: String
    let unitPlural: String
    let calculatedDose: Double?
    let calculatedDoseStandardDeviation: Double?
    let originalUnit: String
    let name: String


    var body: some View {
        VStack(alignment: .leading) {
            Text("\(substanceName), \(name)").font(.headline)
            let pluralizableUnit = PluralizableUnit(singular: unit, plural: unitPlural)
            if isUnknownDosePerUnit {
                Text("\(multiplier.with(pluralizableUnit: pluralizableUnit)) \(administrationRoute.rawValue)")
            } else {
                if isEstimate {
                    if let calculatedDoseStandardDeviation {
                        Text(multiplier.with(pluralizableUnit: pluralizableUnit)) +
                        Text(
                            " = \(calculatedDose?.asRoundedReadableString ?? "...")±\(calculatedDoseStandardDeviation.asRoundedReadableString) \(originalUnit) \(administrationRoute.rawValue)")
                        .foregroundColor(.secondary)
                    } else {
                        Text(multiplier.with(pluralizableUnit: pluralizableUnit)) +
                        Text(
                            " = ~\(calculatedDose?.asRoundedReadableString ?? "...") \(originalUnit) \(administrationRoute.rawValue)")
                        .foregroundColor(.secondary)
                    }
                } else {
                    Text(multiplier.with(pluralizableUnit: pluralizableUnit)) +
                    Text(
                        " = \(calculatedDose?.asRoundedReadableString ?? "...") \(originalUnit) \(administrationRoute.rawValue)")
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        FinishCustomUnitsScreen(
            arguments: CustomUnitArguments.substance(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                administrationRoute: .oral),
            cancel: {},
            onAdded: { _ in })
    }
}
