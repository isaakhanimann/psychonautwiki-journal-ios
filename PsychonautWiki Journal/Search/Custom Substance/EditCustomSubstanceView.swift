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

struct EditCustomSubstanceView: View {

    @ObservedObject var customSubstance: CustomSubstance
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingConfirmation = false
    @State private var units = ""
    @State private var description = ""

    var body: some View {
        List {
            Section("Units") {
                TextField("Units", text: $units)
            }
            Section("Description") {
                TextField("Description", text: $description)
            }
            Section {
                HStack {
                    Spacer()
                    Button {
                        isShowingConfirmation.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        .optionalScrollDismissesKeyboard()
        .confirmationDialog(
            "Are you sure you want to delete this substance?",
            isPresented: $isShowingConfirmation
        ) {
            Button("Delete Substance", role: .destructive) {
                dismiss()
                PersistenceController.shared.viewContext.delete(customSubstance)
                PersistenceController.shared.saveViewContext()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            units = customSubstance.unitsUnwrapped
            description = customSubstance.explanationUnwrapped
        }
        .toolbar {
            ToolbarItem {
                Button("Done") {
                    if !units.isEmpty {
                        customSubstance.units = units
                        customSubstance.explanation = description
                        PersistenceController.shared.saveViewContext()
                    }
                    dismiss()
                }
            }
        }
        .navigationTitle(customSubstance.nameUnwrapped)
    }
}
