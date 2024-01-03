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

struct ChooseDateScreen: View {
    let substanceName: String
    let cancel: () -> Void
    let finish: (SubstanceAndDay) -> Void

    @State private var date = Date()
    @State private var selectedColor = SubstanceColor.red
    @FetchRequest(
        sortDescriptors: []
    ) private var substanceCompanions: FetchedResults<SubstanceCompanion>

    private var doesSubstanceAlreadyHaveColor: Bool {
        substanceCompanions.contains { companion in
            companion.substanceName == substanceName
        }
    }

    private var alreadyUsedColors: [SubstanceColor] {
        Array(Set(substanceCompanions.map { $0.color })).sorted()
    }

    private var otherColors: [SubstanceColor] {
        Array(Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)).sorted()
    }

    var body: some View {
        ChooseDateScreenContent(
            date: $date,
            finish: {
                if !doesSubstanceAlreadyHaveColor {
                    saveSubstanceCompanion()
                }
                finish(SubstanceAndDay(substanceName: substanceName, day: date))
            },
            cancel: cancel,
            isShowingColorPicker: !doesSubstanceAlreadyHaveColor,
            substanceName: substanceName,
            selectedColor: $selectedColor,
            alreadyUsedColors: alreadyUsedColors,
            otherColors: otherColors
        ).onAppear {
            selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        }
    }

    private func saveSubstanceCompanion() {
        let context = PersistenceController.shared.viewContext
        let companion = SubstanceCompanion(context: context)
        companion.substanceName = substanceName
        companion.colorAsText = selectedColor.rawValue
        try? context.save()
    }
}
