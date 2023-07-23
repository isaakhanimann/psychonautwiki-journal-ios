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
import AlertToast

struct ChooseSubstanceScreen: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager
    @AppStorage(PersistenceController.isSkippingInteractionChecksKey) var isSkippingInteractionChecks: Bool = false

    var body: some View {
        ChooseSubstanceContent(
            searchText: $viewModel.searchText,
            isShowingOpenEyeToast: $viewModel.isShowingOpenEyeToast,
            isEyeOpen: viewModel.isEyeOpen,
            isSkippingInteractionChecks: isSkippingInteractionChecks,
            filteredSuggestions: viewModel.filteredSuggestions,
            filteredSubstances: viewModel.filteredSubstances,
            filteredCustomSubstances: viewModel.filteredCustomSubstances,
            dismiss: {dismiss()}
        ).task {
            locationManager.maybeRequestLocation() // because we might need current location on finish screen
        }
    }
}

struct ChooseSubstanceContent: View {
    @Binding var searchText: String
    @Binding var isShowingOpenEyeToast: Bool
    let isEyeOpen: Bool
    let isSkippingInteractionChecks: Bool
    let filteredSuggestions: [Suggestion]
    let filteredSubstances: [Substance]
    let filteredCustomSubstances: [CustomSubstanceModel]
    let dismiss: ()->Void
    @State private var isShowingAddCustomSheet = false
    @StateObject private var hudState = HudState()

    var body: some View {
        NavigationView {
            screen.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .toast(isPresenting: $isShowingOpenEyeToast, duration: 1) {
            AlertToast(
                displayMode: .alert,
                type: .image("Eye Open", .red)
            )
        }
        .hud(isPresented: $hudState.isPresented) {
            InteractionHudContent(
                substanceName: hudState.substanceName,
                interactions: hudState.interactions
            )
        }
    }

    private var screen: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if !filteredSuggestions.isEmpty {
                    Text("Quick Logging").sectionHeaderStyle()
                    ForEach(filteredSuggestions) { suggestion in
                        SuggestionBox(
                            suggestion: suggestion,
                            dismiss: dismiss,
                            isEyeOpen: isEyeOpen
                        )
                        .simultaneousGesture(TapGesture().onEnded{
                            checkInteractions(with: suggestion.substanceName)
                        })
                    }
                    Spacer().frame(height: 20)
                }
                if !filteredSubstances.isEmpty {
                    if filteredSuggestions.isEmpty {
                        ForEach(filteredSubstances) { substance in
                            SubstanceBox(
                                substance: substance,
                                dismiss: dismiss,
                                isEyeOpen: isEyeOpen,
                                isSkippingInteractionChecks: isSkippingInteractionChecks,
                                checkInteractions: checkInteractions
                            )
                        }
                    } else {
                        Text("Regular Logging").sectionHeaderStyle()
                        ForEach(filteredSubstances) { substance in
                            SubstanceBox(
                                substance: substance,
                                dismiss: dismiss,
                                isEyeOpen: isEyeOpen,
                                isSkippingInteractionChecks: isSkippingInteractionChecks,
                                checkInteractions: checkInteractions
                            )
                        }
                    }
                }
                ForEach(filteredCustomSubstances) { custom in
                    CustomSubstanceBox(
                        customSubstanceModel: custom,
                        dismiss: dismiss,
                        isEyeOpen: isEyeOpen
                    )
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
        .optionalScrollDismissesKeyboard()
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .navigationBarTitle("New Ingestion")
    }

    private func checkInteractions(with substanceName: String) {
        guard isEyeOpen else {return}
        guard !isSkippingInteractionChecks else {return}
        let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
        let recentIngestions = PersistenceController.shared.getIngestions(since: twoDaysAgo)
        let names = recentIngestions.map { ing in
            ing.substanceNameUnwrapped
        }
        let allNames = (names + InteractionChecker.additionalInteractionsToCheck).uniqued()
        let interactions = allNames.compactMap { name in
            InteractionChecker.getInteractionBetween(aName: substanceName, bName: name)
        }.uniqued().sorted()
        if !interactions.isEmpty {
            hudState.show(substanceName: substanceName, interactions: interactions)
        }
    }
}

struct ChooseSubstanceContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(previewDeviceNames, id: \.self) { name in
                ChooseSubstanceContent(
                    searchText: .constant(""),
                    isShowingOpenEyeToast: .constant(false),
                    isEyeOpen: true,
                    isSkippingInteractionChecks: false,
                    filteredSuggestions: [
                        Suggestion(
                            substanceName: "MDMA",
                            substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                            units: "mg",
                            route: .insufflated,
                            substanceColor: .pink,
                            dosesAndUnit: [
                                DoseAndUnit(
                                    dose: 20,
                                    units: "mg",
                                    isEstimate: true
                                ),
                                DoseAndUnit(
                                    dose: 30,
                                    units: "mg",
                                    isEstimate: false
                                )
                            ],
                            lastTimeUsed: Date.now.addingTimeInterval(-2*60*60)
                        ),
                        Suggestion(
                            substanceName: "MDMA",
                            substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                            units: "mg",
                            route: .oral,
                            substanceColor: .pink,
                            dosesAndUnit: [
                                DoseAndUnit(
                                    dose: 20,
                                    units: "mg",
                                    isEstimate: false
                                ),
                                DoseAndUnit(
                                    dose: nil,
                                    units: "mg",
                                    isEstimate: false
                                ),
                                DoseAndUnit(
                                    dose: 30,
                                    units: "mg",
                                    isEstimate: false
                                )
                            ],
                            lastTimeUsed: Date.now.addingTimeInterval(-2*60*60)
                        ),
                        Suggestion(
                            substanceName: "Cannabis",
                            substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                            units: "mg",
                            route: .smoked,
                            substanceColor: .green,
                            dosesAndUnit: [
                                DoseAndUnit(
                                    dose: 3,
                                    units: "mg",
                                    isEstimate: false
                                ),
                                DoseAndUnit(
                                    dose: 6,
                                    units: "mg",
                                    isEstimate: true
                                ),
                                DoseAndUnit(
                                    dose: nil,
                                    units: "mg",
                                    isEstimate: false
                                ),
                                DoseAndUnit(
                                    dose: 2.5,
                                    units: "mg",
                                    isEstimate: false
                                )
                            ],
                            lastTimeUsed: Date.now.addingTimeInterval(-2*60*60)
                        ),
                        Suggestion(
                            substanceName: "Coffee",
                            substance: nil,
                            units: "cups",
                            route: .oral,
                            substanceColor: .brown,
                            dosesAndUnit: [
                                DoseAndUnit(
                                    dose: 1,
                                    units: "cups",
                                    isEstimate: false
                                ),
                                DoseAndUnit(
                                    dose: 3,
                                    units: "cups",
                                    isEstimate: false
                                ),
                            ],
                            lastTimeUsed: Date.now.addingTimeInterval(-2*60*60)
                        )
                    ],
                    filteredSubstances: Array(SubstanceRepo.shared.substances.prefix(10)),
                    filteredCustomSubstances: [
                        CustomSubstanceModel(
                        name: "Coffee",
                        description: "The bitter drink",
                        units: "cups"
                    )
                    ],
                    dismiss: {}
                )
                .previewDevice(PreviewDevice(rawValue: name))
                .previewDisplayName(name)
            }
        }
    }
}


