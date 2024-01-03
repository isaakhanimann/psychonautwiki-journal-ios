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

struct CumulativeDose: Identifiable {
    var id: String {
        substanceName
    }

    let substanceName: String
    let substanceColor: SubstanceColor
    let cumulativeRoutes: [CumulativeRouteAndDose]

    init(ingestionsForSubstance: [Ingestion], substanceName: String, substanceColor: SubstanceColor) {
        self.substanceName = substanceName
        self.substanceColor = substanceColor
        let substance = ingestionsForSubstance.first?.substance
        let ingestionsByRoute = Dictionary(grouping: ingestionsForSubstance, by: { $0.administrationRouteUnwrapped })
        cumulativeRoutes = ingestionsByRoute.map { (route: AdministrationRoute, ingestions: [Ingestion]) in
            let roaDose = substance?.getDose(for: route)
            return CumulativeRouteAndDose(route: route, roaDose: roaDose, ingestionForRoute: ingestions)
        }
    }
}

struct CumulativeRouteAndDose: Identifiable {
    var id: AdministrationRoute {
        route
    }

    let route: AdministrationRoute
    let numDots: Int?
    let isEstimate: Bool
    let dose: Double?
    let units: String

    init(route: AdministrationRoute, roaDose: RoaDose?, ingestionForRoute: [Ingestion]) {
        self.route = route
        let units = ingestionForRoute.first?.units ?? "unknown"
        self.units = units
        var totalDose = 0.0
        var isOneDoseUnknown = false
        var isOneDoseAnEstimate = false
        for ingestion in ingestionForRoute {
            if let doseUnwrap = ingestion.doseUnwrapped, ingestion.unitsUnwrapped == units {
                totalDose += doseUnwrap
                if ingestion.isEstimate {
                    isOneDoseAnEstimate = true
                }
            } else {
                isOneDoseUnknown = true
                break
            }
        }
        if isOneDoseUnknown {
            dose = nil
            isEstimate = isOneDoseAnEstimate
            numDots = nil
        } else {
            dose = totalDose
            isEstimate = isOneDoseAnEstimate
            numDots = roaDose?.getNumDots(ingestionDose: totalDose, ingestionUnits: units)
        }
    }

    init(route: AdministrationRoute, numDots: Int?, isEstimate: Bool, dose: Double?, units: String) {
        self.route = route
        self.numDots = numDots
        self.isEstimate = isEstimate
        self.dose = dose
        self.units = units
    }
}
