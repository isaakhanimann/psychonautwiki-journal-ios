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

func getSuggestions(
    sortedIngestions: [Ingestion],
    customUnits: [CustomUnit]
) -> [any SuggestionProtocol] {
    let bySubstance = Dictionary(grouping: sortedIngestions, by: { ingestion in
        ingestion.substanceNameUnwrapped
    })
    return bySubstance.flatMap { (substanceName: String, value: [Ingestion]) in
        getSuggestionsForSubstance(substanceName: substanceName, ingestionsOfSubstance: value)
    }.sorted { sug1, sug2 in
        sug1.sortDate > sug2.sortDate
    }
}

private func getSuggestionsForSubstance(substanceName: String, ingestionsOfSubstance: [Ingestion]) -> [any SuggestionProtocol] {
    let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
    if let substance {
        return Dictionary(grouping: ingestionsOfSubstance, by: { ingestion in
            ingestion.administrationRouteUnwrapped
        }).flatMap { (route: AdministrationRoute, ingestionsOfSubstanceAndRoute: [Ingestion]) in
            let pureSubstanceSuggestions = getPureSubstanceSuggestions(
                route: route,
                pureSubstanceIngestions: ingestionsOfSubstanceAndRoute.filter({ ingestion in
                    ingestion.customUnit == nil
                }),
                substance: substance
            )

            let customUnitSuggestions = getGroupOfCustomUnitSuggestions(
                route: route,
                ingestionsWithCustomUnit: ingestionsOfSubstanceAndRoute.filter({ ingestion in
                    ingestion.customUnit != nil && !(ingestion.customUnit?.isArchived ?? true)
                })
            )
            var result: [any SuggestionProtocol] = customUnitSuggestions
            if let pureSubstanceSuggestions {
                result.append(pureSubstanceSuggestions)
            }
            return result
        }
    } else {
        return Dictionary(grouping: ingestionsOfSubstance, by: { ingestion in
            ingestion.administrationRouteUnwrapped
        }).flatMap { (route: AdministrationRoute, ingestionsOfSubstanceAndRoute: [Ingestion]) in
            let customSubstanceSuggestions = getCustomSubstanceSuggestions(
                route: route,
                customSubstanceIngestions: ingestionsOfSubstanceAndRoute.filter({ ingestion in
                    ingestion.customUnit == nil && ingestion.substance == nil
                })
            )

            let customUnitSuggestions = getGroupOfCustomUnitSuggestions(
                route: route,
                ingestionsWithCustomUnit: ingestionsOfSubstanceAndRoute.filter({ ingestion in
                    ingestion.customUnit != nil
                })
            )
            var result: [any SuggestionProtocol] = customUnitSuggestions
            if let customSubstanceSuggestions {
                result.append(customSubstanceSuggestions)
            }
            return result
        }
    }

}

private let maxNumberOfSuggestions = 8

private func getPureSubstanceSuggestions(route: AdministrationRoute, pureSubstanceIngestions: [Ingestion], substance: Substance) -> PureSubstanceSuggestions? {
    if let ingestion = pureSubstanceIngestions.first {
        let dosesAndUnit = pureSubstanceIngestions.map { ingestion in
            RegularDoseAndUnit(dose: ingestion.doseUnwrapped, units: ingestion.unitsUnwrapped, isEstimate: ingestion.isEstimate, estimatedDoseStandardDeviation: ingestion.estimatedDoseStandardDeviationUnwrapped)
        }
        return PureSubstanceSuggestions(
            route: route,
            substance: substance,
            substanceColor: ingestion.substanceColor,
            dosesAndUnit: Array(dosesAndUnit.uniqued().prefix(maxNumberOfSuggestions)),
            sortDate: pureSubstanceIngestions.compactMap { $0.creationDate }.max() ?? Date.distantPast
        )
    }
    return nil
}

private func getCustomSubstanceSuggestions(route: AdministrationRoute, customSubstanceIngestions: [Ingestion]) -> CustomSubstanceSuggestions? {
    if let ingestion = customSubstanceIngestions.first, let customSubstanceName = ingestion.substanceName {
        let dosesAndUnit = customSubstanceIngestions.map { ingestion in
            RegularDoseAndUnit(dose: ingestion.doseUnwrapped, units: ingestion.unitsUnwrapped, isEstimate: ingestion.isEstimate, estimatedDoseStandardDeviation: ingestion.estimatedDoseStandardDeviationUnwrapped)
        }
        return CustomSubstanceSuggestions(
            administrationRoute: route,
            customSubstanceName: customSubstanceName,
            dosesAndUnit: Array(dosesAndUnit.uniqued().prefix(maxNumberOfSuggestions)),
            substanceColor: ingestion.substanceColor,
            sortDate: customSubstanceIngestions.compactMap { $0.creationDate }.max() ?? Date.distantPast
        )
    }
    return nil
}

private func getGroupOfCustomUnitSuggestions(route: AdministrationRoute, ingestionsWithCustomUnit: [Ingestion]) -> [CustomUnitSuggestions] {
    let byUnit = Dictionary(grouping: ingestionsWithCustomUnit, by: { ingestion in
        ingestion.customUnit?.nameUnwrapped
    })
    return byUnit.compactMap { (_: String?, sameUnitIngestions: [Ingestion]) in
        if let firstIngestion = sameUnitIngestions.first, let customUnit = firstIngestion.customUnit {
            let doses = Array(sameUnitIngestions.map({ ingestion in
                CustomUnitDoseSuggestion(
                    dose: ingestion.doseUnwrapped,
                    isEstimate: ingestion.isEstimate,
                    estimatedStandardDeviation: ingestion.estimatedDoseStandardDeviationUnwrapped
                )
            }).uniqued().prefix(maxNumberOfSuggestions))
            return CustomUnitSuggestions(
                customUnit: customUnit,
                doses: doses,
                substanceColor: firstIngestion.substanceColor,
                sortDate: sameUnitIngestions.compactMap { $0.creationDate }.max() ?? Date.distantPast)
        }
        return nil
    }
}
