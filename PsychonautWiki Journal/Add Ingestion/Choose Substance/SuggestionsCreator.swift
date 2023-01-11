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

    init(sortedIngestions: [Ingestion]) {
        sortedIngestions.forEach { ingestion in
            maybeAddSuggestion(from: ingestion)
        }
    }

    private func maybeAddSuggestion(from ingestion: Ingestion) {
        if let foundSuggestion = suggestions.first(where: { sugg in
            sugg.substanceName == ingestion.substanceNameUnwrapped && sugg.route == ingestion.administrationRouteUnwrapped
        }) {
            maybeAdd(ingestion: ingestion, to: foundSuggestion)
        } else {
            addNewSuggestion(from: ingestion)
        }
    }

    private func maybeAdd(ingestion: Ingestion, to suggestion: Suggestion) {
        let doseAndUnit = DoseAndUnit(dose: ingestion.doseUnwrapped, units: ingestion.unitsUnwrapped, isEstimate: ingestion.isEstimate)
        if !suggestion.dosesAndUnit.contains(doseAndUnit) {
            suggestion.dosesAndUnit.append(doseAndUnit)
        }
    }

    private func addNewSuggestion(from ingestion: Ingestion) {
        let substanceName = ingestion.substanceNameUnwrapped
        let units = ingestion.unitsUnwrapped
        suggestions.append(
            Suggestion(
                substanceName: substanceName,
                substance: SubstanceRepo.shared.getSubstance(name: substanceName),
                units: units,
                route: ingestion.administrationRouteUnwrapped,
                substanceColor: ingestion.substanceColor,
                dosesAndUnit: [DoseAndUnit(dose: ingestion.doseUnwrapped, units: units, isEstimate: ingestion.isEstimate)]
            )
        )
    }
}


class Suggestion: Identifiable {
    var id: String {
        substanceName + route.rawValue
    }
    let substanceName: String
    let substance: Substance?
    let units: String
    let route: AdministrationRoute
    let substanceColor: SubstanceColor
    var dosesAndUnit: [DoseAndUnit]

    init(substanceName: String, substance: Substance?, units: String, route: AdministrationRoute, substanceColor: SubstanceColor, dosesAndUnit: [DoseAndUnit]) {
        self.substanceName = substanceName
        self.substance = substance
        self.units = units
        self.route = route
        self.substanceColor = substanceColor
        self.dosesAndUnit = dosesAndUnit
    }
}

struct DoseAndUnit: Hashable, Identifiable {
    var id: String {
        (dose?.description ?? "") + (units ?? "")
    }
    let dose: Double?
    let units: String?
    let isEstimate: Bool
}

struct CustomSubstanceModel: Identifiable {
    var id: String {
        name + units // id must be different from just name because else there is a bug when showing both the custom substance and original substance
    }
    let name: String
    let units: String
}
