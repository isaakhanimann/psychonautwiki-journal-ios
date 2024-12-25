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
import AppIntents

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
    let filteredSuggestions: [any SuggestionProtocol]
    let filteredSubstances: [Substance]
    let filteredCustomUnits: [CustomUnit]
    let filteredCustomSubstances: [CustomSubstanceModel]
    let dismiss: () -> Void

    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
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
                CustomSubstanceChooseDoseScreen(arguments: arguments, dismiss: dismiss)
            })
            .navigationDestination(for: ChooseOtherRouteScreenArguments.self, destination: { arguments in
                ChooseOtherRouteScreen(arguments: arguments, dismiss: dismiss)
            })
            .navigationDestination(for: CustomSubstanceChooseRouteScreenArguments.self, destination: { arguments in
                CustomSubstanceChooseRouteScreen(arguments: arguments, dismiss: dismiss)
            })
            .navigationDestination(for: SubstanceAndRoute.self) { arguments in
                let substanceName = arguments.substance.name
                if substanceName == "MDMA", arguments.administrationRoute == .oral {
                    ChooseMDMADoseScreen(
                        dismiss: dismiss,
                        navigateToCustomUnitChooseDose: { customUnit in
                            navPath.append(customUnit)
                        }
                    )
                } else {
                    ChooseDoseScreen(
                        arguments: arguments,
                        dismiss: dismiss,
                        navigateToCustomUnitChooseDose: { customUnit in
                            navPath.append(customUnit)
                        }
                    )
                }
            }
            .navigationDestination(for: CustomUnit.self) { customUnit in
                CustomUnitsChooseDoseScreen(customUnit: customUnit, dismiss: dismiss, navigateToCustomUnitChooseDose: { newCustomUnit in
                    navPath.append(newCustomUnit)
                })
            }
        }
        .toast(isPresenting: $isShowingOpenEyeToast, duration: 1) {
            AlertToast(
                displayMode: .alert,
                type: .image("Eye Open", .red))
        }
    }

    @State private var isShowingAddCustomSheet = false
    @AppStorage("isAddIngestionSiriTipVisible") private var isSiriTipVisible = true

    private var screen: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                SiriTipView(intent: AddIngestionIntent(), isVisible: $isSiriTipVisible).padding(.horizontal)
                ForEach(filteredSuggestions, id: \.id) { suggestion in
                    if let pureSubstanceSuggestions = suggestion as? PureSubstanceSuggestions {
                        PureSubstanceSuggestionView(pureSubstanceSuggestions: pureSubstanceSuggestions, isEyeOpen: isEyeOpen)
                    } else if let customUnitSuggestions = suggestion as? CustomUnitSuggestions {
                        CustomUnitSuggestionView(customUnitSuggestions: customUnitSuggestions, isEyeOpen: isEyeOpen)
                    } else if let customSubstanceSuggestions = suggestion as? CustomSubstanceSuggestions {
                        CustomSubstanceSuggestionView(customSubstanceSuggestions: customSubstanceSuggestions, isEyeOpen: isEyeOpen)
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
                ForEach(filteredSubstances) { substance in
                    SubstanceBox(
                        substance: substance,
                        dismiss: dismiss,
                        isEyeOpen: isEyeOpen)
                }
                Button {
                    isShowingAddCustomSheet.toggle()
                } label: {
                    Label("New Custom Substance", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }.padding(.horizontal)
                    .sheet(isPresented: $isShowingAddCustomSheet) {
                        AddCustomSubstanceView(searchText: searchText) { customChooseRouteScreenArguments in
                            navPath.append(customChooseRouteScreenArguments)
                        }
                    }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .navigationBarTitle("New Ingestion")
    }
}
