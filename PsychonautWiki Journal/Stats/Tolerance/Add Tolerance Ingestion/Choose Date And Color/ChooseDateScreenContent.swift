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

struct ChooseDateScreenContent: View {
    @Binding var date: Date
    let finish: () -> Void
    let cancel: () -> Void
    let isShowingColorPicker: Bool
    let substanceName: String
    @Binding var selectedColor: SubstanceColor
    let alreadyUsedColors: [SubstanceColor]
    let otherColors: [SubstanceColor]

    var body: some View {
        screen.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: cancel)
            }
            ToolbarItem(placement: .primaryAction) {
                DoneButton(action: finish)
            }
        }
    }

    var screen: some View {
        Form {
            DatePicker("Ingestion Date",
                       selection: $date,
                       displayedComponents: [.date])
                .datePickerStyle(.graphical)
            if isShowingColorPicker {
                Section {
                    NavigationLink {
                        ColorPickerScreen(
                            selectedColor: $selectedColor,
                            alreadyUsedColors: alreadyUsedColors,
                            otherColors: otherColors
                        )
                    } label: {
                        HStack {
                            Text("\(substanceName) Color")
                            Spacer()
                            Image(systemName: "circle.fill").foregroundColor(selectedColor.swiftUIColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("Choose Date")
    }
}

#Preview {
    NavigationStack {
        let alreadyUsedColors = [SubstanceColor.green, .pink]
        let otherColors = Array(Set(SubstanceColor.allCases).subtracting(alreadyUsedColors))
        ChooseDateScreenContent(
            date: .constant(Date.now),
            finish: {},
            cancel: {},
            isShowingColorPicker: true,
            substanceName: "MDMA",
            selectedColor: .constant(.blue),
            alreadyUsedColors: alreadyUsedColors,
            otherColors: otherColors
        )
    }
}
