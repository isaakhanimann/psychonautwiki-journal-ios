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

struct AddToleranceIngestionScreen: View {
    @StateObject private var viewModel = ChooseSubstanceScreen.ViewModel()
    @Environment(\.dismiss) var dismiss
    let finish: (SubstanceAndDay) -> Void

    var body: some View {
        NavigationStack {
            List(viewModel.filteredSubstances, id: \.name) { substance in
                if substance.tolerance?.halfToleranceInHours != nil || substance.tolerance?.zeroToleranceInHours != nil {
                    NavigationLink {
                        ChooseDateScreen(substanceName: substance.name,
                                         cancel: { dismiss() },
                                         finish: finish)
                    } label: {
                        Text(substance.name)
                            .font(.headline)
                    }
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        Text(substance.name)
                            .font(.headline)
                        Spacer()
                        Text("No tolerance info")
                    }.foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Temp. Ingestion")
            .scrollDismissesKeyboard(.interactively)
            .searchable(text: $viewModel.searchText, prompt: "Search substance")
            .disableAutocorrection(true)
        }
    }
}
