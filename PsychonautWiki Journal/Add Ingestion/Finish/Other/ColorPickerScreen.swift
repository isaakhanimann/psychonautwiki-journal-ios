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

struct ColorPickerScreen: View {

    @Binding var selectedColor: SubstanceColor
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
        }.navigationTitle("Choose Color")
    }

    private func button(for color: SubstanceColor) -> some View {
        Button {
            selectedColor = color
            dismiss()
        } label: {
            if selectedColor == color {
                HStack {
                    Label(color.name, systemImage: "circle.fill").foregroundColor(color.swiftUIColor)
                    Spacer()
                    Image(systemName: "checkmark")
                }
            } else {
                Label(color.name, systemImage: "circle.fill").foregroundColor(color.swiftUIColor)
            }
        }

    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let alreadyUsed: Set = [SubstanceColor.blue, .red, .orange]
            ColorPickerScreen(
                selectedColor: .constant(.purple),
                alreadyUsedColors: alreadyUsed,
                otherColors: Set(SubstanceColor.allCases).subtracting(alreadyUsed)
            )
        }
    }
}
