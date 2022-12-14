//
//  ChooseSubstanceContent.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 14.12.22.
//

import SwiftUI

struct ChooseSubstanceContent: View {
    @Binding var searchText: String
    let filteredSuggestions: [Suggestion]
    let filteredSubstances: [Substance]
    let filteredCustomSubstances: [CustomSubstanceModel]
    let dismiss: ()->Void

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    if !filteredSuggestions.isEmpty {
                        Section("Quick Logging") {
                            ForEach(filteredSuggestions) { suggestion in
                                SuggestionBox(suggestion: suggestion, dismiss: dismiss)
                            }
                        }.padding(.horizontal)
                    }
                    if !filteredSubstances.isEmpty {
                        Section("All Substances") {
                            ForEach(filteredSubstances) { substance in
                                SubstanceBox(substance: substance, dismiss: dismiss)
                            }
                        }.padding(.horizontal)
                    }
                    if !filteredCustomSubstances.isEmpty {
                        Section("Custom Substances") {
                            ForEach(filteredCustomSubstances) { custom in
                                CustomSubstanceBox(customSubstanceModel: custom, dismiss: dismiss)                            }
                        }.padding(.horizontal)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .disableAutocorrection(true)
            .navigationBarTitle("Add Ingestion")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChooseSubstanceContent_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceContent(
            searchText: .constant(""),
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
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: nil,
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: 30,
                            units: "mg"
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
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: nil,
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: 30,
                            units: "mg"
                        )
                    ]
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
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: 6,
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: nil,
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: 2.5,
                            units: "mg"
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
                            units: "cups"
                        ),
                        DoseAndUnit(
                            dose: 3,
                            units: "cups"
                        ),
                    ]
                )
            ],
            filteredSubstances: SubstanceRepo.shared.substances,
            filteredCustomSubstances: [],
            dismiss: {}
        )
    }
}
