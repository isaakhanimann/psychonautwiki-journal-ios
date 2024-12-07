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

struct AddCustomSubstanceView: View {

    let searchText: String
    let onAdded: (CustomSubstanceChooseRouteScreenArguments) -> Void

    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField(
                        "Name",
                        text: $viewModel.name,
                        prompt: Text("Enter Name")
                    )
                    .disableAutocorrection(true)
                }
                Section("Description") {
                    TextField(
                        "Description",
                        text: $viewModel.explanation,
                        prompt: Text("Enter Description")
                    )
                    .disableAutocorrection(true)
                }
                Section("Units") {
                    UnitsPicker(units: $viewModel.units)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.name) { newValue in
                if !isEyeOpen {
                    let allSubstances = SubstanceRepo.shared.substances
                    let originalFiltered = SearchLogic.getFilteredSubstancesSorted(substances: allSubstances, searchText: newValue, namesToSortBy: [])
                    if newValue.count > 3 && originalFiltered.count > 0 {
                        isEyeOpen = true
                    }
                }
            }
            .onAppear(perform: {
                viewModel.name = searchText
            })
            .navigationTitle("Create Custom")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if viewModel.isEverythingNeededDefined {
                        DoneButton {
                            viewModel.saveCustom {
                                onAdded(CustomSubstanceChooseRouteScreenArguments(substanceName: viewModel.name, units: viewModel.units))
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddCustomSubstanceView(searchText: "My subs", onAdded: {_ in })
}
