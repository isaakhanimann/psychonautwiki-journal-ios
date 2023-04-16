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

final class HudState: ObservableObject {
    @Published var isPresented: Bool = false
    private(set) var text: String = ""

    func show(substanceName: String, interactions: [Interaction]) {
        self.text = HudState.getText(substanceName: substanceName, interactions: interactions)
        withAnimation {
            isPresented = true
        }
    }

    static func getText(substanceName: String, interactions: [Interaction]) -> String {
        let grouped = Dictionary(grouping: interactions, by: {$0.interactionType})
        let sortedGrouped = grouped.sorted { interaction1, interaction2 in
            interaction1.0.dangerCount > interaction2.0.dangerCount
        }
        return sortedGrouped.map { (type: InteractionType, interactions: [Interaction]) in
            var result = ""
            switch type {
            case .uncertain:
                result = "Uncertain interaction"
            case .unsafe:
                result = "Unsafe interaction"
            case .dangerous:
                result = "Dangerous interaction"
            }
            let otherSubstances = interactions.flatMap { interaction in
                [interaction.aName, interaction.bName]
            }.uniqued().filter {$0 != substanceName}
            var otherSubstanceText = ""
            if let sub = otherSubstances.first, otherSubstances.count == 1 {
                otherSubstanceText = sub
            } else {
                let untilLastIndex = max(otherSubstances.count-1, 0)
                let first = otherSubstances.prefix(untilLastIndex)
                otherSubstanceText = first.joined(separator: ", ")
                if let last = otherSubstances.last {
                    otherSubstanceText += " and " + last
                }
            }
            result = result + " with " + otherSubstanceText + "."
            return result
        }.joined(separator: "\n")
    }
}
