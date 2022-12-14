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
                    if !filteredSuggestions.isEmpty {
                        Section("All Substances") {
                            ForEach(filteredSuggestions) { suggestion in
                                SuggestionBox(suggestion: suggestion, dismiss: dismiss)
                            }
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


struct Suggestion: Identifiable {
    var id: String {
        substanceName + route.rawValue
    }
    let substanceName: String
    let substance: Substance?
    let units: String
    let route: AdministrationRoute
    let substanceColor: SubstanceColor
    let dosesAndUnit: [DoseAndUnit]
}

struct DoseAndUnit: Hashable, Identifiable {
    var id: String {
        (dose?.description ?? "") + (units ?? "")
    }
    let dose: Double?
    let units: String?
}

struct CustomSubstanceModel {
    let name: String
    let units: String
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
