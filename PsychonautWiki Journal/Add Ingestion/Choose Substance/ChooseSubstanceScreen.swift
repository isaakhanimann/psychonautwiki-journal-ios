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
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ChooseSubstanceContent(
            searchText: $viewModel.searchText,
            isShowingOpenEyeToast: $viewModel.isShowingOpenEyeToast,
            isEyeOpen: viewModel.isEyeOpen,
            filteredSuggestions: viewModel.filteredSuggestions,
            filteredSubstances: viewModel.filteredSubstances,
            filteredCustomSubstances: viewModel.filteredCustomSubstances,
            dismiss: {dismiss()}
        )
    }
}

struct ChooseSubstanceContent: View {
    @Binding var searchText: String
    @Binding var isShowingOpenEyeToast: Bool
    let isEyeOpen: Bool
    let filteredSuggestions: [Suggestion]
    let filteredSubstances: [Substance]
    let filteredCustomSubstances: [CustomSubstanceModel]
    let dismiss: ()->Void
    @State private var isShowingAddCustomSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    if !filteredSuggestions.isEmpty {
                        Section("Quick Logging") {
                            ForEach(filteredSuggestions) { suggestion in
                                SuggestionBox(suggestion: suggestion, dismiss: dismiss)
                            }
                        }.padding(.horizontal)
                        Spacer().frame(height: 20)
                    }
                    if !filteredSubstances.isEmpty {
                        if filteredSuggestions.isEmpty {
                            Section {
                                ForEach(filteredSubstances) { substance in
                                    SubstanceBox(substance: substance, dismiss: dismiss, isEyeOpen: isEyeOpen)
                                }
                            }.padding(.horizontal)
                        } else {
                            Section("All Substances") {
                                ForEach(filteredSubstances) { substance in
                                    SubstanceBox(substance: substance, dismiss: dismiss, isEyeOpen: isEyeOpen)
                                }
                            }.padding(.horizontal)
                        }

                        Spacer().frame(height: 20)
                    }
                    if filteredCustomSubstances.isEmpty {
                        customSubstancesGroup.padding(.horizontal)
                    } else {
                        Section("Custom Substances") {
                            customSubstancesGroup
                        }.padding(.horizontal)
                    }
                }
            }
            .optionalScrollDismissesKeyboard()
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .disableAutocorrection(true)
            .navigationBarTitle("New Ingestion")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toast(isPresenting: $isShowingOpenEyeToast) {
                AlertToast(
                    displayMode: .alert,
                    type: .image("Eye Open", .red)
                )
            }
        }
    }

    var customSubstancesGroup: some View {
        Group {
            ForEach(filteredCustomSubstances) { custom in
                CustomSubstanceBox(
                    customSubstanceModel: custom,
                    dismiss: dismiss
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
        }
    }
}

struct ChooseSubstanceContent_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceContent(
            searchText: .constant(""),
            isShowingOpenEyeToast: .constant(true),
            isEyeOpen: true,
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
                            dose: nil,
                            units: "mg",
                            isEstimate: false
                        ),
                        DoseAndUnit(
                            dose: 30,
                            units: "mg",
                            isEstimate: false
                        )
                    ]
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
                    ]
                ),
                Suggestion(
                    substanceName: "Cannabis",
                    substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                    units: "mg (THC)",
                    route: .smoked,
                    substanceColor: .green,
                    dosesAndUnit: [
                        DoseAndUnit(
                            dose: 3,
                            units: "mg  (THC)",
                            isEstimate: false
                        ),
                        DoseAndUnit(
                            dose: 6,
                            units: "mg (THC)",
                            isEstimate: true
                        ),
                        DoseAndUnit(
                            dose: nil,
                            units: "mg (THC)",
                            isEstimate: false
                        ),
                        DoseAndUnit(
                            dose: 2.5,
                            units: "mg (THC)",
                            isEstimate: false
                        )
                    ]
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
                    ]
                )
            ],
            filteredSubstances: SubstanceRepo.shared.substances,
            filteredCustomSubstances: [CustomSubstanceModel(name: "Coffee", units: "cups")],
            dismiss: {}
        )
    }
}


