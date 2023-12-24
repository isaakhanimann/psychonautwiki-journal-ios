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

struct ChooseDoseScreen: View {

    let arguments: SubstanceAndRoute
    let dismiss: () -> Void
    @State private var selectedUnits: String? = UnitPickerOptions.mg.rawValue
    @State private var selectedPureDose: Double?
    @State private var isEstimate = false
    @State private var isShowingNext = false

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    var body: some View {
        ChooseDoseScreenContent(
            substance: arguments.substance,
            administrationRoute: arguments.administrationRoute,
            dismiss: dismiss,
            isEyeOpen: isEyeOpen,
            selectedPureDose: $selectedPureDose,
            selectedUnits: $selectedUnits,
            isEstimate: $isEstimate,
            isShowingNext: $isShowingNext
        )
        .task {
            let routeUnits = arguments.substance.getDose(for: arguments.administrationRoute)?.units
            if let routeUnits {
                selectedUnits = routeUnits
            }
        }
    }
}

struct ChooseDoseScreenContent: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    let isEyeOpen: Bool
    @Binding var selectedPureDose: Double?
    @Binding var selectedUnits: String?
    @Binding var isEstimate: Bool
    @Binding var isShowingNext: Bool
    var roaDose: RoaDose? {
        substance.getDose(for: administrationRoute)
    }


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
                    suggestedNote: suggestedNote)) {
                        NextLabel()
                    }
            }
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Use Unknown Dose", value: FinishIngestionScreenArguments(
            substanceName: substance.name,
            administrationRoute: administrationRoute,
            dose: nil,
            units: selectedUnits,
            isEstimate: isEstimate,
            suggestedNote: suggestedNote))
    }

    private var screen: some View {
        Form {
            doseSection
            if substance.name == "Nicotine" {
                Section("Nicotine Content vs Dose") {
                    Text("The nicotine inhaled by the average smoker per cigarette is indicated on the package. The nicotine content of the cigarette itself is much higher as on average only about 10% of the cigarette’s nicotine is inhaled.\nMore nicotine is inhaled when taking larger and more frequent puffs or by blocking the cigarette filter ventilation holes.\nNicotine yields from electronic cigarettes are also highly correlated with the device type and brand, liquid nicotine concentration, and PG/VG ratio, and to a lower significance with electrical power. Nicotine yields from 15 puffs may vary 50-fold.")
                }
            }
            if isEyeOpen {
                if administrationRoute == .smoked && substance.categories.contains("opioid") {
                    ChasingTheDragonSection()
                }
                Section("Info") {
                    if administrationRoute == .smoked || administrationRoute == .inhaled {
                        Text("Depending on your smoking/inhalation method different amounts of substance are lost before entering the body. The dosage should reflect the amount of substance that is actually inhaled.")
                    }
                    NavigationLink("Testing") {
                        TestingScreen()
                    }
                    NavigationLink("Dosage Guide") {
                        HowToDoseScreen()
                    }
                    if roaDose?.shouldUseVolumetricDosing ?? false {
                        NavigationLink("Volumetric Dosing Recommended") {
                            VolumetricDosingScreen()
                        }
                    }
                }
                Section("Disclaimer") {
                    Text(Self.doseDisclaimer)
                }
            }
        }
        .optionalScrollDismissesKeyboard()
        .navigationBarTitle("\(substance.name) Dose")
    }

    var suggestedNote: String? {
        guard let impureDose, let selectedUnits, purityInPercent != 100 && purityInPercent != nil else {return nil}
        return "\(impureDose.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) \(selectedUnits) with \(purityText)% purity"
    }

    static let doseDisclaimer = "Dosage information is gathered from users and various resources. It is not a recommendation and should be verified with other sources for accuracy. Always start with lower doses due to differences between individual body weight, tolerance, metabolism, and personal sensitivity."

    @State private var purityText = ""
    var purityInPercent: Double? {
        getDouble(from: purityText)
    }
    private var impureDose: Double? {
        guard let selectedPureDose = selectedPureDose else { return nil }
        guard let purityInPercent, purityInPercent != 0 else { return nil }
        return selectedPureDose/purityInPercent * 100
    }

    var doseSection: some View {
        return Section {
            if !substance.isApproved {
                Text("Info is not approved by PsychonautWiki administrators.")
            }
            if let remark = substance.dosageRemark {
                Text(remark)
                    .foregroundColor(.secondary)
            }
            DoseRow(roaDose: roaDose)
            DosePicker(
                roaDose: roaDose,
                doseMaybe: $selectedPureDose,
                selectedUnits: $selectedUnits,
                focusOnAppear: true
            )
            if isEyeOpen {
                HStack {
                    Image(systemName: "arrow.down")
                    TextField("Purity", text: $purityText).keyboardType(.decimalPad)
                    Spacer()
                    Text("%")
                }
                if let impureDose {
                    Text("\(impureDose.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) \(selectedUnits ?? "")").font(.title)
                }
            }
            Toggle("Dose is an Estimate", isOn: $isEstimate).tint(.accentColor)
            unknownDoseLink
        } header: {
            Text("Pure \(administrationRoute.rawValue.capitalized) Dose")
        } footer: {
            if let units = roaDose?.units,
               let clarification = DosesScreen.getUnitClarification(for: units) {
                Section {
                    Text(clarification)
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct ChooseDoseScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(previewDeviceNames, id: \.self) { name in
                NavigationStack {
                    ChooseDoseScreenContent(
                        substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!,
                        administrationRoute: .oral,
                        dismiss: {},
                        isEyeOpen: true,
                        selectedPureDose: .constant(20),
                        selectedUnits: .constant("mg"),
                        isEstimate: .constant(false),
                        isShowingNext: .constant(false)
                    )
                }
                .previewDevice(PreviewDevice(rawValue: name))
                .previewDisplayName(name)
            }
        }
    }
}
