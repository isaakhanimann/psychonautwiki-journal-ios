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

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ChooseDoseScreenContent(
            substance: substance,
            administrationRoute: administrationRoute,
            dismiss: dismiss,
            purity: $viewModel.purity,
            selectedPureDose: $viewModel.selectedPureDose,
            selectedUnits: $viewModel.selectedUnits,
            isEstimate: $viewModel.isEstimate,
            isShowingNext: $viewModel.isShowingNext,
            impureDoseText: viewModel.impureDoseText,
            impureDoseRounded: viewModel.impureDoseRounded
        )
        .task {
            let routeUnits = substance.getDose(for: administrationRoute)?.units
            viewModel.initializeUnits(routeUnits: routeUnits)
        }
    }
}

struct ChooseDoseScreenContent: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: () -> Void
    @Binding var purity: Double
    @Binding var selectedPureDose: Double?
    @Binding var selectedUnits: String?
    @Binding var isEstimate: Bool
    @Binding var isShowingNext: Bool
    var impureDoseText: String
    var impureDoseRounded: Double?
    @State private var isShowingUnknownDoseAlert = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    var roaDose: RoaDose? {
        substance.getDose(for: administrationRoute)
    }

    var body: some View {
        Form {
            doseSection
            puritySection
            if substance.name == "Nicotine" {
                Section("Nicotine Content vs Dose") {
                    Text("The nicotine inhaled by the average smoker per cigarette is indicated on the package. The nicotine content of the cigarette itself is much higher as on average only about 10% of the cigarette’s nicotine is inhaled.\nMore nicotine is inhaled when taking larger and more frequent puffs or by blocking the cigarette filter ventilation holes.\nNicotine yields from electronic cigarettes are also highly correlated with the device type and brand, liquid nicotine concentration, and PG/VG ratio, and to a lower significance with electrical power. Nicotine yields from 15 puffs may vary 50-fold.")
                }
            }
            if isEyeOpen {
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
            }
            Section("Disclaimer") {
                Text(Self.doseDisclaimer)
            }
        }
        .optionalScrollDismissesKeyboard()
        .navigationBarTitle("\(substance.name) Dose")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    hideKeyboard()
                } label: {
                    Label("Hide Keyboard", systemImage: "keyboard.chevron.compact.down").labelStyle(.iconOnly)
                }
                Button {
                    isShowingNext = true
                } label: {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }

            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    if isEyeOpen {
                        isShowingUnknownDoseAlert.toggle()
                    } else {
                        selectedPureDose = nil
                        isShowingNext = true
                    }
                } label: {
                    Label("Use Unknown Dose", systemImage: "exclamationmark.triangle").labelStyle(.titleAndIcon)
                }
                .alert("Unknown Danger", isPresented: $isShowingUnknownDoseAlert) {
                    Button("Log Anyway", role: .destructive) {
                        selectedPureDose = nil
                        isShowingNext = true
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingUnknownDoseAlert.toggle()
                    }
                } message: {
                    Text("Taking an unknown dose can lead to overdose. Dose your substance with a milligram scale or volumetrically. Test your substance to make sure that it really is what you believe it is and doesn’t contain any dangerous adulterants. If you live in Austria, Belgium, Canada, France, Italy, Netherlands, Spain or Switzerland there are anonymous and free drug testing services available to you, else you can purchase an inexpensive reagent testing kit.")
                }
                NavigationLink(
                    destination: FinishIngestionScreen(
                        substanceName: substance.name,
                        administrationRoute: administrationRoute,
                        dose: selectedPureDose,
                        units: selectedUnits,
                        isEstimate: isEstimate,
                        dismiss: dismiss,
                        suggestedNote: suggestedNote
                    ),
                    isActive: $isShowingNext
                ) {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }.disabled(selectedPureDose==nil)
            }
        }
    }

    var suggestedNote: String? {
        guard let impureDoseRounded, let selectedUnits, impureDoseRounded != 100 else {return nil}
        return "\(impureDoseRounded.formatted()) \(selectedUnits) with \(Int(purity))% purity"
    }

    static let doseDisclaimer = "Dosage information is gathered from users and various resources. It is not a recommendation and should be verified with other sources for accuracy. Always start with lower doses due to differences between individual body weight, tolerance, metabolism, and personal sensitivity."

    private var puritySection: some View {
        Section("Purity Adjusted Dose") {
            VStack {
                Text(impureDoseText)
                    .font(.title2.bold())
                Text("\(Int(purity))%")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Slider(
                    value: $purity,
                    in: 1...100,
                    step: 1
                ) {
                    Text("Purity")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("100")
                }
            }
        }
    }

    var doseSection: some View {
        return Section {
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
            Toggle("Dose is an Estimate", isOn: $isEstimate).tint(.accentColor).padding(.bottom, 5)
        } header: {
            Text("Pure Dose")
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
                NavigationView {
                    ChooseDoseScreenContent(
                        substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!,
                        administrationRoute: .oral,
                        dismiss: {},
                        purity: .constant(100),
                        selectedPureDose: .constant(20),
                        selectedUnits: .constant("mg"),
                        isEstimate: .constant(false),
                        isShowingNext: .constant(false),
                        impureDoseText: "20 mg"
                    )
                }
                .previewDevice(PreviewDevice(rawValue: name))
                .previewDisplayName(name)
            }
        }
    }
}
