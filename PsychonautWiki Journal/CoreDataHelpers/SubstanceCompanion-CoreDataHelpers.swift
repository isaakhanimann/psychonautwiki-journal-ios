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
import Foundation

extension SubstanceCompanion {
    var color: SubstanceColor {
        if let text = colorAsText, let color = SubstanceColor(rawValue: text) {
            return color
        } else {
            return SubstanceColor.red
        }
    }

    var substanceNameUnwrapped: String {
        substanceName ?? "Unknown"
    }

    var ingestionsUnwrapped: [Ingestion] {
        ingestions?.allObjects as? [Ingestion] ?? []
    }

    static var fakeMDMA: SubstanceCompanion {
        let companion = SubstanceCompanion(context: PersistenceController.preview.viewContext)
        companion.substanceName = "MDMA"
        companion.colorAsText = SubstanceColor.pink.rawValue
        return companion
    }

    static var fakeLSD: SubstanceCompanion {
        let companion = SubstanceCompanion(context: PersistenceController.preview.viewContext)
        companion.substanceName = "LSD"
        companion.colorAsText = SubstanceColor.blue.rawValue
        return companion
    }
}
