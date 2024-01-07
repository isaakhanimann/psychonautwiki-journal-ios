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

struct CustomUnitsChooseSubstanceScreen: View {
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) private var ingestions: FetchedResults<Ingestion>

    private var substancesFilteredAndSorted: [Substance] {
        let substanceNamesInOrder = ingestions.prefix(500).map { ing in
            ing.substanceNameUnwrapped
        }.uniqued()
        return SearchLogic.getFilteredSubstancesSorted(
            substances: SubstanceRepo.shared.substances,
            searchText: searchText,
            namesToSortBy: substanceNamesInOrder
        )
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(substancesFilteredAndSorted) { sub in
                    NavigationLink(value: ChooseRouteScreenArguments(substance: sub)) {
                        SubstanceRowLabel(substance: sub)
                    }
                }
                if substancesFilteredAndSorted.isEmpty {
                    Text("No Results")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.interactively)
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .navigationTitle("Choose Substance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: ChooseRouteScreenArguments.self, destination: { arguments in
                ChooseRouteScreen(substance: arguments.substance, dismiss: dismissSheet)
            })
            .navigationDestination(for: ChooseOtherRouteScreenArguments.self, destination: { arguments in
                ChooseOtherRouteScreen(arguments: arguments, dismiss: dismissSheet)
            })
            .navigationDestination(for: SubstanceAndRoute.self) { arguments in
                FinishCustomUnitsScreen(substanceAndRoute: arguments, dismiss: dismissSheet)
            }
        }
    }

    private func dismissSheet() {
        dismiss()
    }
}

private struct SubstanceRowLabel: View {
    let substance: Substance

    var body: some View {
        VStack(alignment: .leading) {
            Text(substance.name).font(.headline)
            let commonNames = substance.commonNames.joined(separator: ", ")
            if !commonNames.isEmpty {
                Text(commonNames).font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    List(SubstanceRepo.shared.substances.prefix(20)) { substance in
        SubstanceRowLabel(substance: substance)
    }.listStyle(.plain)
}
