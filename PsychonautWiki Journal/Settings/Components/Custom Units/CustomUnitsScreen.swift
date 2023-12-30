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

struct CustomUnitsScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomUnit.creationDate, ascending: false)]
    ) private var customUnits: FetchedResults<CustomUnit>
    @State private var isAddShown = false

    var body: some View {
        Group {
            if customUnits.isEmpty {
                Text("No custom units yet")
                    .foregroundColor(.secondary)
            } else {
                List(customUnits) { customUnit in
                    NavigationLink {
                        EditCustomUnitsScreen(customUnit: customUnit)
                    } label: {
                        CustomUnitRow(
                            name: customUnit.nameUnwrapped,
                            substanceName: customUnit.substanceNameUnwrapped,
                            color: customUnit.color?.swiftUIColor,
                            unit: customUnit.unitUnwrapped,
                            isEstimate: customUnit.isEstimate,
                            dose: customUnit.doseUnwrapped,
                            originalUnit: customUnit.originalUnitUnwrapped,
                            isArchived: customUnit.isArchived
                        )
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
}


struct CustomUnitRow: View {

    let name: String
    let substanceName: String
    let color: Color?
    let unit: String
    let isEstimate: Bool
    let dose: Double?
    let originalUnit: String
    let isArchived: Bool

    var body: some View {
        HStack {
            ColorRectangle(color: color ?? Color.gray)
            Spacer().frame(width: 10)
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text(substanceName)
                Group {
                    if let dose {
                        Text("1 \(unit) = \(isEstimate ? "~" : "")\(dose.formatted()) \(originalUnit)")
                    } else {
                        Text("1 \(unit) of unknown dose")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Spacer()
            if isArchived {
                Image(systemName: "archivebox").foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    List {
        CustomUnitRow(
            name: "Pink rocket",
            substanceName: "Substance A",
            color: SubstanceColor.auburn.swiftUIColor,
            unit: "pill",
            isEstimate: true,
            dose: 20,
            originalUnit: "mg",
            isArchived: true
        )
    }
}
