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

func getEverythingForEachLine(from ingestions: [Ingestion]) -> [EverythingForOneLine] {
    let dosePairs: [(String, Double)] = ingestions.compactMap({ ing in
        guard let dose = ing.doseUnwrapped else {return nil}
        return (ing.substanceNameUnwrapped, dose)
    })
    let maxDoses = Dictionary(dosePairs) { dose1, dose2 in
        max(dose1, dose2)
    }
    return ingestions.map { ingestion in
        let substanceName = ingestion.substanceNameUnwrapped
        let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
        let roaDuration = substance?.getDuration(for: ingestion.administrationRouteUnwrapped)
        let roaDose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
        var horizontalWeight = 0.5
        if let dose = ingestion.doseUnwrapped, let units = ingestion.units, let roaDose {
            let doseType = roaDose.getRangeType(for: dose, with: units)
            switch doseType {
            case .thresh:
                horizontalWeight = 0
            case .light:
                horizontalWeight = 0.25
            case .common:
                horizontalWeight = 0.5
            case .strong:
                horizontalWeight = 0.75
            case .heavy:
                horizontalWeight = 1
            case .none:
                horizontalWeight = 0.5
            }
        }
        var verticalWeight = 1.0
        if let dose = ingestion.doseUnwrapped, let max = maxDoses[substanceName] {
            verticalWeight = dose/max
        }
        return EverythingForOneLine(
            roaDuration: roaDuration,
            startTime: ingestion.timeUnwrapped,
            horizontalWeight: horizontalWeight,
            verticalWeight: verticalWeight,
            color: ingestion.substanceColor
        )
    }
}
