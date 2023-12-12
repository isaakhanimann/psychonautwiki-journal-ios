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
        sortDescriptors: []
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
                        Text("Hello")
                    } label: {
                        Text(customUnit.substanceNameUnwrapped)
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
            Text("Choose Substance")
        })
        .navigationTitle("Custom Units")
        .dismissWhenTabTapped()
    }
}


struct CustomUnitRow: View {

    let substanceName: String
    let color: Color
    let unit: String
    let dose: Double
    let originalUnit: String

    var body: some View {
        HStack {
            ColorRectangle(color: color)
            Spacer().frame(width: 10)
            VStack(alignment: .leading) {
                Text("\(substanceName), \(unit)")
                    .font(.headline)
                Text("1 \(unit) = \(dose.formatted()) \(originalUnit) \(substanceName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    List {
        CustomUnitRow(
            substanceName: "Substance A",
            color: SubstanceColor.auburn.swiftUIColor,
            unit: "rocket pills",
            dose: 20,
            originalUnit: "mg")
    }
}
