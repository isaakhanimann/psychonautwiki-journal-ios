//
//  SuggestionsCreator.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 14.12.22.
//

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
        name
    }
    let name: String
    let units: String
}
