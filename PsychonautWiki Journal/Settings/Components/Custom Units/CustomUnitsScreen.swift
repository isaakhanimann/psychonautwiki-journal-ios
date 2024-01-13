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

// MARK: - CustomUnitsScreen

struct CustomUnitsScreen: View {
    var body: some View {
        Group {
            List {
                if customUnits.isEmpty {
                    Text("No custom units")
                        .foregroundColor(.secondary)
                }
                NavigationLink {
                    CustomUnitsArchiveScreen()
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                ForEach(customUnits) { customUnit in
                    NavigationLink {
                        EditCustomUnitsScreen(customUnit: customUnit)
                    } label: {
                        CustomUnitRow(customUnit: customUnit)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddShown.toggle()
                } label: {
                    Label("Add Custom Unit", systemImage: "plus").labelStyle(.iconOnly)
                }
            }
        }
        .fullScreenCover(isPresented: $isAddShown, content: {
            CustomUnitsChooseSubstanceScreen()
        })
        .navigationTitle("Custom Units")
        .dismissWhenTabTapped()
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomUnit.creationDate, ascending: false)],
        predicate: NSPredicate(
            format: "isArchived == %@",
            NSNumber(value: false))) private var customUnits: FetchedResults<CustomUnit>
    @State private var isAddShown = false

}
