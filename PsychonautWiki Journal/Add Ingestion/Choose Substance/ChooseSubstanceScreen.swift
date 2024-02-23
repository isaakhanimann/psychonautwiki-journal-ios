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

import AlertToast
import SwiftUI

struct ChooseSubstanceScreen: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        ChooseSubstanceContent(
            searchText: $viewModel.searchText,
            isShowingOpenEyeToast: $viewModel.isShowingOpenEyeToast,
            isEyeOpen: viewModel.isEyeOpen,
            filteredSuggestions: viewModel.filteredSuggestions,
            filteredSubstances: viewModel.filteredSubstances,
            filteredCustomUnits: viewModel.filteredCustomUnits,
            filteredCustomSubstances: viewModel.filteredCustomSubstances,
            dismiss: { dismiss() }).task {
            locationManager.maybeRequestLocation() // because we might need current location on finish screen
        }
    }
}

struct ChooseSubstanceContent: View {
    @Binding var searchText: String
    @Binding var isShowingOpenEyeToast: Bool
    let isEyeOpen: Bool
    let filteredSuggestions: [Suggestion]
    let filteredSubstances: [Substance]
    let filteredCustomUnits: [CustomUnit]
    let filteredCustomSubstances: [CustomSubstanceModel]
    let dismiss: () -> Void

    var body: some View {
        NavigationStack {
            screen.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: FinishIngestionScreenArguments.self) { arguments in
                FinishIngestionScreen(arguments: arguments, dismiss: dismiss)
            }
            .navigationDestination(for: AddCustomUnitArguments.self) { arguments in
                AddCustomUnitsScreen(substanceAndRoute: arguments.substanceAndRoute)
            }
            .navigationDestination(for: AddIngestionDestination.self) { destination in
                switch destination {
                case .interactions(let substance):
                    AcknowledgeInteractionsView(substance: substance, dismiss: dismiss)
                case .saferUse(let substance):
                    AcknowledgeSaferUseScreen(substance: substance, dismiss: dismiss)
                case .saferRoutes:
                    SaferRoutesScreen()
                }
            }
            .navigationDestination(for: ChooseRouteScreenArguments.self, destination: { arguments in
                ChooseRouteScreen(substance: arguments.substance, dismiss: dismiss)
            })
            .navigationDestination(for: CustomChooseDoseScreenArguments.self, destination: { arguments in
                CustomChooseDoseScreen(arguments: arguments, dismiss: dismiss)
            })
            .navigationDestination(for: ChooseOtherRouteScreenArguments.self, destination: { arguments in
                ChooseOtherRouteScreen(arguments: arguments, dismiss: dismiss)
            })
            .navigationDestination(for: CustomChooseRouteScreenArguments.self, destination: { arguments in
                CustomChooseRouteScreen(arguments: arguments, dismiss: dismiss)
            })
            .navigationDestination(for: SubstanceAndRoute.self) { arguments in
                let substanceName = arguments.substance.name
                if substanceName == "Cannabis", arguments.administrationRoute == .smoked {
                    ChooseCannabisSmokedDoseScreen(dismiss: dismiss)
                } else if substanceName == "Alcohol", arguments.administrationRoute == .oral {
                    ChooseAlcoholDoseScreen(dismiss: dismiss)
                } else if substanceName == "Caffeine", arguments.administrationRoute == .oral {
                    ChooseCaffeineDoseScreen(dismiss: dismiss)
                } else if substanceName == "MDMA", arguments.administrationRoute == .oral {
                    ChooseMDMADoseScreen(dismiss: dismiss)
                } else if substanceName == "Psilocybin mushrooms", arguments.administrationRoute == .oral {
                    ChooseShroomsDoseScreen(dismiss: dismiss)
                } else {
                    ChooseDoseScreen(arguments: arguments, dismiss: dismiss)
                }
            }
            .navigationDestination(for: CustomUnit.self) { customUnit in
                CustomUnitsChooseDoseScreen(customUnit: customUnit, dismiss: dismiss)
            }
        }
        .toast(isPresenting: $isShowingOpenEyeToast, duration: 1) {
            AlertToast(
                displayMode: .alert,
                type: .image("Eye Open", .red))
        }
    }

    @State private var isShowingAddCustomSheet = false

    private var screen: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if !filteredSuggestions.isEmpty {
                    ForEach(filteredSuggestions) { suggestion in
                        SuggestionBox(
                            suggestion: suggestion,
                            dismiss: dismiss,
                            isEyeOpen: isEyeOpen)
                    }
                }
                ForEach(filteredCustomUnits) { customUnit in
                    CustomUnitBox(customUnit: customUnit)
                }
                ForEach(filteredCustomSubstances) { custom in
                    CustomSubstanceBox(
                        customSubstanceModel: custom,
                        isEyeOpen: isEyeOpen)
                }
                if !filteredSubstances.isEmpty {
                    if filteredSuggestions.isEmpty {
                        ForEach(filteredSubstances) { substance in
                            SubstanceBox(
                                substance: substance,
                                dismiss: dismiss,
                                isEyeOpen: isEyeOpen)
                        }
                    } else {
                        ForEach(filteredSubstances) { substance in
                            SubstanceBox(
                                substance: substance,
                                dismiss: dismiss,
                                isEyeOpen: isEyeOpen)
                        }
                    }
                }
                Button {
                    isShowingAddCustomSheet.toggle()
                } label: {
                    Label("New Custom Substance", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }
                .sheet(isPresented: $isShowingAddCustomSheet) {
                    AddCustomSubstanceView()
                }
            }.padding(.horizontal)
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .navigationBarTitle("New Ingestion")
    }
}

#Preview {
    ChooseSubstanceContent(
        searchText: .constant(""),
        isShowingOpenEyeToast: .constant(false),
        isEyeOpen: true,
        filteredSuggestions: [
            Suggestion(
                substanceName: "Ketamine",
                substance: SubstanceRepo.shared.getSubstance(name: "Ketamine"),
                units: "mg",
                route: .insufflated,
                substanceColor: .orange,
                dosesAndUnit: [
                    RegularDoseAndUnit(
                        dose: 20,
                        units: "mg",
                        isEstimate: true,
                        estimatedDoseVariance: 3),
                    RegularDoseAndUnit(
                        dose: 30,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                ],
                customUnitDoses: [
                    CustomUnitDose(
                        dose: 2,
                        isEstimate: false,
                        estimatedDoseVariance: nil,
                        customUnit: .previewSample)
                ],
                customUnits: [],
                lastTimeUsed: Date.now.addingTimeInterval(-2 * 60 * 60)),
            Suggestion(
                substanceName: "MDMA",
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                units: "mg",
                route: .oral,
                substanceColor: .pink,
                dosesAndUnit: [
                    RegularDoseAndUnit(
                        dose: 20,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                    RegularDoseAndUnit(
                        dose: nil,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                    RegularDoseAndUnit(
                        dose: 30,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                ],
                customUnitDoses: [],
                customUnits: [],
                lastTimeUsed: Date.now.addingTimeInterval(-2 * 60 * 60)),
            Suggestion(
                substanceName: "Cannabis",
                substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                units: "mg",
                route: .smoked,
                substanceColor: .green,
                dosesAndUnit: [
                    RegularDoseAndUnit(
                        dose: 3,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                    RegularDoseAndUnit(
                        dose: 6,
                        units: "mg",
                        isEstimate: true,
                        estimatedDoseVariance: 1),
                    RegularDoseAndUnit(
                        dose: nil,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                    RegularDoseAndUnit(
                        dose: 2.5,
                        units: "mg",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                ],
                customUnitDoses: [],
                customUnits: [],
                lastTimeUsed: Date.now.addingTimeInterval(-2 * 60 * 60)),
            Suggestion(
                substanceName: "Coffee",
                substance: nil,
                units: "cups",
                route: .oral,
                substanceColor: .brown,
                dosesAndUnit: [
                    RegularDoseAndUnit(
                        dose: 1,
                        units: "cups",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                    RegularDoseAndUnit(
                        dose: 3,
                        units: "cups",
                        isEstimate: false,
                        estimatedDoseVariance: nil),
                ],
                customUnitDoses: [],
                customUnits: [],
                lastTimeUsed: Date.now.addingTimeInterval(-2 * 60 * 60)),
        ],
        filteredSubstances: Array(SubstanceRepo.shared.substances.prefix(10)),
        filteredCustomUnits: [
            .previewSample
        ],
        filteredCustomSubstances: [
            CustomSubstanceModel(
                name: "Coffee",
                description: "The bitter drink",
                units: "cups"),
        ],
        dismiss: { })
}
