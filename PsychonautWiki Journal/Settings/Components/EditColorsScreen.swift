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

struct EditColorsScreen: View {

    @FetchRequest(
        sortDescriptors: []
    ) var substanceCompanions: FetchedResults<SubstanceCompanion>

    var alreadyUsedColors: Set<SubstanceColor> {
        Set(substanceCompanions.map { comp in
            comp.color
        })
    }

    var otherColors: Set<SubstanceColor> {
        Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
    }

    var body: some View {
        List {
            Section {
                if substanceCompanions.isEmpty {
                    Text("No colors added yet")
                } else {
                    ForEach(substanceCompanions) { companion in
                        NavigationLink {
                            CompanionColorPickerScreen(
                                companion: companion,
                                alreadyUsedColors: alreadyUsedColors,
                                otherColors: otherColors
                            )
                        } label: {
                            CompanionRow(
                                name: companion.substanceNameUnwrapped,
                                color: companion.color.swiftUIColor
                            )
                        }
                    }
                }
            }
        }.navigationTitle("Edit Colors")
    }
}

struct CompanionColorPickerScreen: View {

    let companion: SubstanceCompanion
    let alreadyUsedColors: Set<SubstanceColor>
    let otherColors: Set<SubstanceColor>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            if !otherColors.isEmpty {
                Section("Unused Colors") {
                    ForEach(Array(otherColors)) { color in
                        button(for: color)
                    }
                }
            }
            if !alreadyUsedColors.isEmpty {
                Section("Used Colors") {
                    ForEach(Array(alreadyUsedColors)) { color in
                        button(for: color)
                    }
                }
            }
        }
        .navigationTitle("Choose Color")
        .dismissWhenTabTapped()
    }

    private func button(for color: SubstanceColor) -> some View {
        Button {
            companion.colorAsText = color.rawValue
            PersistenceController.shared.saveViewContext()
            dismiss()
        } label: {
            if companion.color == color {
                HStack {
                    Label(color.rawValue, systemImage: "circle.fill").foregroundColor(color.swiftUIColor)
                    Spacer()
                    Image(systemName: "checkmark")
                }
            } else {
                Label(color.rawValue, systemImage: "circle.fill").foregroundColor(color.swiftUIColor)
            }
        }

    }
}


struct CompanionRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Image(systemName: "circle.fill")
                .font(.title2)
                .foregroundColor(color)
        }
    }
}

struct CompanionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CompanionRow(name: "MDMA", color: .pink)
        }
    }
}
