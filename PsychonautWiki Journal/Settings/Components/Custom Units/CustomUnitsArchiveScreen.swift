// Copyright (c) 2024. Isaak Hanimann.
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

struct CustomUnitsArchiveScreen: View {

    @State private var customUnitToEdit: CustomUnit?

    var body: some View {
        Group {
            if customUnits.isEmpty {
                Text("No archived custom units")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(customUnits) { customUnit in
                        Button(action: {
                            customUnitToEdit = customUnit
                        }, label: {
                            CustomUnitRow(customUnit: customUnit).foregroundColor(.primary)
                        })
                    }
                }
            }
        }
        .sheet(item: $customUnitToEdit, content: { customUnit in
            NavigationStack {
                EditCustomUnitsScreen(customUnit: customUnit)
            }
        })
        .navigationTitle("Archive")
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomUnit.creationDate, ascending: false)],
        predicate: NSPredicate(
            format: "isArchived == %@",
            NSNumber(value: true))) private var customUnits: FetchedResults<CustomUnit>

}
