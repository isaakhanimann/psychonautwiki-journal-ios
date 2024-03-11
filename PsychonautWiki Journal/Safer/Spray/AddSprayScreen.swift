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

struct AddSprayScreen: View {
    @State private var name = ""
    @State private var sizeInMlText = ""
    @State private var sizeInMl: Double?
    @State private var numSpraysText = ""
    @State private var numSprays: Double?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Name") {
                    TextField("Spray Name", text: $name)
                        .font(.title)
                        .padding(.vertical, 3)
                }
                Section {
                    VStack {
                        HStack {
                            TextField("Volume", text: $sizeInMlText)
                                .keyboardType(.decimalPad)
                            Text("ml")
                        }
                        .font(.title)
                        TextField("Number of sprays", text: $numSpraysText)
                            .font(.title)
                            .keyboardType(.decimalPad)
                    }.padding(.vertical, 3)
                } header: {
                    Text("Size")
                } footer: {
                    Text("Note: fill it into the spray bottle and count the number of sprays. To make sure the last couple of sprays still work properly use a small spray bottle (5ml) and fill it completely.")
                }.listRowSeparator(.hidden)
            }
            .navigationTitle("Add Spray")
            .onChange(of: numSpraysText) { newValue in
                numSprays = getDouble(from: newValue)
            }
            .onChange(of: sizeInMlText) { newValue in
                sizeInMl = getDouble(from: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let sizeInMl, let numSprays, !name.isEmpty {
                        Button("Save") {
                            save(sizeInMl: sizeInMl, numSprays: numSprays)
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func save(sizeInMl: Double, numSprays: Double) {
        let spray = Spray(context: PersistenceController.shared.viewContext)
        spray.creationDate = Date()
        spray.name = name
        spray.contentInMl = sizeInMl
        spray.numSprays = numSprays
        spray.isPreferred = true
        do {
            try PersistenceController.shared.viewContext.save()
        } catch {
            assertionFailure("Failed to save spray")
        }
    }
}

#Preview {
    NavigationStack {
        AddSprayScreen()
    }
}
