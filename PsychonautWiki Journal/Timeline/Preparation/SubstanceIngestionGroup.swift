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

import Foundation

struct IngestionMinInfoForTimeline: Codable, Equatable {
    static func == (lhs: IngestionMinInfoForTimeline, rhs: IngestionMinInfoForTimeline) -> Bool {
        lhs.time == rhs.time
    }

    let substanceName: String
    let route: AdministrationRoute
    let onsetDelayInHours: Double
    let time: Date
    let endTime: Date?
    let dose: Double?
    let color: SubstanceColor
}

private func getIngestionMinInfoForTimeline(ingestions: [Ingestion]) -> [IngestionMinInfoForTimeline] {
    ingestions.map { ingestion in
        IngestionMinInfoForTimeline(
            substanceName: ingestion.substanceNameUnwrapped,
            route: ingestion.administrationRouteUnwrapped,
            onsetDelayInHours: ingestion.stomachFullnessUnwrapped?.onsetDelayForOralInHours ?? 0,
            time: ingestion.timeUnwrapped,
            endTime: ingestion.endTime,
            dose: ingestion.pureSubstanceDose,
            color: ingestion.substanceColor
        )
    }
}

// return value is ready to be sent to live activity
func getSubstanceIngestionGroups(ingestions: [Ingestion]) -> [SubstanceIngestionGroup] {
    let ingestionsMinInfoForTimeline = getIngestionMinInfoForTimeline(ingestions: ingestions)
    let substanceDict = Dictionary(grouping: ingestionsMinInfoForTimeline) { minInfo in
        minInfo.substanceName
    }
    let substanceIngestionGroups: [SubstanceIngestionGroup] = substanceDict.compactMap { (substanceName: String, ingestionMinInfoForLines: [IngestionMinInfoForTimeline]) in
        guard let color = ingestionMinInfoForLines.first?.color else { return nil }
        let routeDict = Dictionary(grouping: ingestionMinInfoForLines) { value in
            value.route
        }
        let routeMinInfos = routeDict.map { (route: AdministrationRoute, values: [IngestionMinInfoForTimeline]) in
            let ingestions = values.map { ingestionMinInfo in
                IngestionMinInfo(
                    dose: ingestionMinInfo.dose,
                    time: ingestionMinInfo.time,
                    endTime: ingestionMinInfo.endTime,
                    onsetDelayInHours: ingestionMinInfo.onsetDelayInHours
                )
            }
            return RouteMinInfo(
                route: route,
                ingestions: ingestions
            )
        }
        return SubstanceIngestionGroup(
            substanceName: substanceName,
            color: color,
            routeMinInfos: routeMinInfos
        )
    }
    return substanceIngestionGroups
}
