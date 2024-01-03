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

class SuggestionsCreator {
    var suggestions: [Suggestion] = []
    private let maxNumberOfSuggestions = 10

    init(sortedIngestions: [Ingestion], customUnits: [CustomUnit]) {
        let bySubstance = Dictionary(grouping: sortedIngestions, by: { ingestion in
            ingestion.substanceNameUnwrapped
        })
        suggestions = bySubstance.flatMap { (substanceName: String, value: [Ingestion]) in
            Dictionary(grouping: value, by: { ingestion in
                ingestion.administrationRouteUnwrapped
            }).map { (route: AdministrationRoute, groupedBySubstanceAndRoute: [Ingestion]) in
                let firstIngestion = groupedBySubstanceAndRoute.first
                let filteredCustomUnits = customUnits.filter { customUnit in
                    customUnit.substanceNameUnwrapped == substanceName && customUnit.administrationRouteUnwrapped == route
                }
                return Suggestion(
                    substanceName: substanceName,
                    substance: SubstanceRepo.shared.getSubstance(name: substanceName),
                    units: firstIngestion?.unitsUnwrapped ?? "",
                    route: firstIngestion?.administrationRouteUnwrapped ?? .oral,
                    substanceColor: firstIngestion?.substanceColor ?? .red,
                    dosesAndUnit: Array(groupedBySubstanceAndRoute
                        .map { ing in
                            DoseAndUnit(dose: ing.doseUnwrapped, units: ing.unitsUnwrapped, isEstimate: ing.isEstimate)
                        }
                        .uniqued()
                        .prefix(maxNumberOfSuggestions)),
                    customUnits: filteredCustomUnits,
                    lastTimeUsed: groupedBySubstanceAndRoute.map { $0.timeUnwrapped }.max() ?? .now
                )
            }
        }.sorted { sug1, sug2 in
            sug1.lastTimeUsed > sug2.lastTimeUsed
        }
    }
}
