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

// MARK: - ChooseDoseScreen

struct ChooseDoseScreen: View {
    let arguments: SubstanceAndRoute
    let dismiss: () -> Void
    let navigateToCustomUnitChooseDose: (CustomUnit) -> Void
    @State private var selectedUnits: String = UnitPickerOptions.mg.rawValue
    @State private var selectedPureDose: Double?
    @State private var selectedDoseDeviation: Double?
    @State private var isEstimate = false
    @State private var isShowingNext = false

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen = false

    var body: some View {
        ChooseDoseScreenContent(
            substance: arguments.substance,
            administrationRoute: arguments.administrationRoute,
            dismiss: dismiss,
            navigateToCustomUnitChooseDose: navigateToCustomUnitChooseDose,
            isEyeOpen: isEyeOpen,
            selectedPureDose: $selectedPureDose,
            selectedDoseDeviation: $selectedDoseDeviation,
            selectedUnits: $selectedUnits,
            isEstimate: $isEstimate,
            isShowingNext: $isShowingNext)
            .task {
                let routeUnits = arguments.substance.getDose(for: arguments.administrationRoute)?.units
                if let routeUnits {
                    selectedUnits = routeUnits
                }
            }
    }
}

// MARK: - ChooseDoseScreenContent

struct ChooseDoseScreenContent: View {
    init(
        substance: Substance,
        administrationRoute: AdministrationRoute,
        dismiss: @escaping () -> Void,
        navigateToCustomUnitChooseDose: @escaping (CustomUnit) -> Void,
        isEyeOpen: Bool,
        selectedPureDose: Binding<Double?>,
        selectedDoseDeviation: Binding<Double?>,
        selectedUnits: Binding<String>,
        isEstimate: Binding<Bool>,
        isShowingNext: Binding<Bool>) {
        self.substance = substance
        self.administrationRoute = administrationRoute
        self.dismiss = dismiss
        self.navigateToCustomUnitChooseDose = navigateToCustomUnitChooseDose
        self.isEyeOpen = isEyeOpen
        self._selectedPureDose = selectedPureDose
        self._selectedDoseDeviation = selectedDoseDeviation
        self._selectedUnits = selectedUnits
        self._isEstimate = isEstimate
        self._isShowingNext = isShowingNext
        customUnits = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \CustomUnit.creationDate, ascending: false)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "isArchived == %@", NSNumber(value: false)),
                NSPredicate(format: "substanceName == %@", substance.name),
                NSPredicate(format: "administrationRoute == %@", administrationRoute.rawValue),
            ]))
    }

    static let doseDisclaimer =
        "Dosage information is gathered from users and various resources. It is not a recommendation and should be verified with other sources for accuracy. Always start with lower doses due to differences between individual body weight, tolerance, metabolism, and personal sensitivity."

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    let navigateToCustomUnitChooseDose: (CustomUnit) -> Void
    let isEyeOpen: Bool
    @Binding var selectedPureDose: Double?
    @Binding var selectedDoseDeviation: Double?
    @Binding var selectedUnits: String
    @Binding var isEstimate: Bool
    @Binding var isShowingNext: Bool

    var body: some View {
        screen.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: FinishIngestionScreenArguments(
                    substanceName: substance.name,
                    administrationRoute: administrationRoute,
                    dose: selectedPureDose,
                    units: selectedUnits,
                    isEstimate: isEstimate,
                    estimatedDoseStandardDeviation: selectedDoseDeviation))
                {
                    NextLabel()
                }
            }
        }
    }

    private var customUnits: FetchRequest<CustomUnit>


    @FocusState private var isDoseFieldFocused: Bool
    @FocusState private var isEstimatedDeviationFocused: Bool
    @State private var isAddCustomUnitSheetShown: Bool = false

    private var roaDose: RoaDose? {
        substance.getDose(for: administrationRoute)
    }

    @State private var isDosageRemarkExpanded = false

    private var doseSection: some View {
        Section {
            VStack(alignment: .leading) {
                if !substance.isApproved {
                    Text("Info is not approved by PsychonautWiki moderators.")
                }
                if let remark = substance.dosageRemark {
                    HStack {
                        Text(remark).lineLimit(isDosageRemarkExpanded ? nil : 2)
                        if !isDosageRemarkExpanded {
                            Image(systemName: "chevron.down")
                        }
                    }
                   .onTapGesture {
                        withAnimation {
                            isDosageRemarkExpanded.toggle()
                        }
                    }
                }
                if let roaDose {
                    RoaDoseRow(roaDose: roaDose)
                }
                DosePicker(
                    roaDose: roaDose,
                    doseMaybe: $selectedPureDose,
                    selectedUnits: $selectedUnits)
                .focused($isDoseFieldFocused)
                .onFirstAppear {
                    isDoseFieldFocused = true
                }
                Toggle("Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                    .onChange(of: isEstimate, perform: { newIsEstimate in
                        if newIsEstimate {
                            isEstimatedDeviationFocused = true
                        }
                    })
                let units = selectedUnits.isEmpty ? roaDose?.units ?? "" : selectedUnits
                if isEstimate {
                    HStack {
                        Image(systemName: "plusminus")
                        TextField(
                            "Estimated standard deviation",
                            value: $selectedDoseDeviation,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($isEstimatedDeviationFocused)
                        Spacer()
                        Text(units)
                    }
                }
                if let selectedPureDose, let selectedDoseDeviation {
                    StandardDeviationConfidenceIntervalExplanation(mean: selectedPureDose, standardDeviation: selectedDoseDeviation, unit: units)
                }
            }
        } header: {
            Text("Pure \(administrationRoute.rawValue.capitalized) Dose")
        } footer: {
            if
                let units = roaDose?.units,
                let clarification = DosesSection.getUnitClarification(for: units)
            {
                Section {
                    Text(clarification)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private var unknownDoseLink: some View {
        NavigationLink("Use unknown dose", value: FinishIngestionScreenArguments(
            substanceName: substance.name,
            administrationRoute: administrationRoute,
            dose: nil,
            units: selectedUnits,
            isEstimate: isEstimate,
            estimatedDoseStandardDeviation: nil))
    }

    var customUnitPrompt: String {
        if substance.name == "Cannabis" && administrationRoute == .smoked {
            "Prefer to log weight of bud, hash or log another unit related to joint, vaporizer or bong?"
        } else if (substance.name == "Psilocybin mushrooms") {
            "Prefer to log weight of mushrooms instead of mg Psilocybin?"
        } else if (substance.name == "Alcohol") {
            "Prefer to log number of drinks, beer or wine instead of g of Ethanol?"
        } else if (substance.name == "Caffeine") {
            "Prefer to log coffee, tea or energy drink instead of mg Caffeine?"
        } else {
            "Prefer to use a different unit such as \(sampleUnitText)?"
        }
    }

    var sampleUnitText: String {
        switch administrationRoute {
        case .oral:
            "pills, capsules or raw powder weight"
        case .smoked:
            "hits"
        case .insufflated:
            "sprays, spoons, scoops, lines or raw powder weight"
        case .buccal:
            "pouches"
        case .transdermal:
            "patches"
        default:
            "pills, sprays, spoons or powder weight"
        }
    }

    private var screen: some View {
        Form {
            doseSection
            if isEyeOpen {
                Section {
                    Text(customUnitPrompt)
                    Button("Add a custom unit") {
                        isAddCustomUnitSheetShown.toggle()
                    }
                    ForEach(customUnits.wrappedValue) { customUnit in
                        NavigationLink(value: customUnit) {
                            Text("Log \(customUnit.pluralizableUnit.plural) (\(customUnit.nameUnwrapped))")
                        }
                    }
                }
                Section {
                    unknownDoseLink
                }
                if substance.name == "Nicotine" {
                    Section("Nicotine Content vs Dose") {
                        Text(
                            "The nicotine inhaled by the average smoker per cigarette is indicated on the package. The nicotine content of the cigarette itself is much higher as on average only about 10% of the cigarette’s nicotine is inhaled.\nMore nicotine is inhaled when taking larger and more frequent puffs or by blocking the cigarette filter ventilation holes.\nNicotine yields from electronic cigarettes are also highly correlated with the device type and brand, liquid nicotine concentration, and PG/VG ratio, and to a lower significance with electrical power. Nicotine yields from 15 puffs may vary 50-fold.")
                    }
                }
                if administrationRoute == .smoked, substance.categories.contains("opioid") {
                    ChasingTheDragonSection()
                }
                let isSmokedRoute = administrationRoute == .smoked || administrationRoute == .inhaled
                let shouldUseVolumetricDosing = roaDose?.shouldUseVolumetricDosing ?? false
                if isSmokedRoute || shouldUseVolumetricDosing {
                    Section("Info") {
                        if isSmokedRoute {
                            Text(
                                "Depending on your smoking/inhalation method different amounts of substance are lost before entering the body. The dosage should reflect the amount of substance that is actually inhaled.")
                        }
                        if shouldUseVolumetricDosing {
                            NavigationLink("Volumetric Dosing Recommended") {
                                VolumetricDosingScreen()
                            }
                        }
                    }
                }
                Section("Disclaimer") {
                    Text(Self.doseDisclaimer)
                }
            }
        }
        .sheet(isPresented: $isAddCustomUnitSheetShown, content: {
            NavigationStack {
                FinishCustomUnitsScreen(
                    arguments: CustomUnitArguments.substance(substance: substance, administrationRoute: administrationRoute),
                    cancel: {
                        isAddCustomUnitSheetShown = false
                    },
                    onAdded: { customUnit in
                        isAddCustomUnitSheetShown = false
                        navigateToCustomUnitChooseDose(customUnit)
                    })
            }
        })
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitle("\(substance.name) Dose")
    }

}

#Preview {
    NavigationStack {
        ChooseDoseScreenContent(
            substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!,
            administrationRoute: .oral,
            dismiss: { },
            navigateToCustomUnitChooseDose: { _ in},
            isEyeOpen: true,
            selectedPureDose: .constant(20),
            selectedDoseDeviation: .constant(2),
            selectedUnits: .constant("mg"),
            isEstimate: .constant(true),
            isShowingNext: .constant(false))
    }
}
