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

protocol SuggestionProtocol: Identifiable {
    var id: String { get }
    var sortDate: Date { get }

    func isInResult(searchText: String, substanceNames: [String]) -> Bool
}

struct PureSubstanceSuggestions: SuggestionProtocol {
    func isInResult(searchText: String, substanceNames: [String]) -> Bool {
        substanceNames.contains(substance.name)
    }

    let id: String
    let route: AdministrationRoute
    let substance: Substance
    let substanceColor: SubstanceColor
    let dosesAndUnit: [RegularDoseAndUnit]
    let sortDate: Date

    init(route: AdministrationRoute, substance: Substance, substanceColor: SubstanceColor, dosesAndUnit: [RegularDoseAndUnit], sortDate: Date) {
        self.route = route
        self.substance = substance
        self.substanceColor = substanceColor
        self.dosesAndUnit = dosesAndUnit
        self.sortDate = sortDate
        self.id = substance.name + route.rawValue
    }
}

struct CustomUnitSuggestions: SuggestionProtocol {
    func isInResult(searchText: String, substanceNames: [String]) -> Bool {
        if searchText.isEmpty {
            return true
        }
        return substanceNames.contains(customUnit.substanceNameUnwrapped) || customUnit.nameUnwrapped.lowercased().contains(searchText.lowercased()) || customUnit.unitUnwrapped.lowercased().contains(searchText.lowercased()) ||
        customUnit.noteUnwrapped.lowercased().contains(searchText.lowercased())
    }

    let id: String
    let customUnit: CustomUnit
    let doses: [CustomUnitDoseSuggestion]
    let substanceColor: SubstanceColor
    let sortDate: Date

    init(customUnit: CustomUnit, doses: [CustomUnitDoseSuggestion], substanceColor: SubstanceColor, sortDate: Date) {
        self.customUnit = customUnit
        self.doses = doses
        self.substanceColor = substanceColor
        self.sortDate = sortDate
        self.id = customUnit.nameUnwrapped + customUnit.substanceNameUnwrapped
    }
}

struct CustomSubstanceSuggestions: SuggestionProtocol {
    func isInResult(searchText: String, substanceNames: [String]) -> Bool {
        if searchText.isEmpty {
            return true
        }
        return customSubstanceName.lowercased().contains(searchText.lowercased())
    }
    
    let id: String
    let administrationRoute: AdministrationRoute
    let customSubstanceName: String
    let dosesAndUnit: [RegularDoseAndUnit]
    let substanceColor: SubstanceColor
    let sortDate: Date

    init(administrationRoute: AdministrationRoute, customSubstanceName: String, dosesAndUnit: [RegularDoseAndUnit], substanceColor: SubstanceColor, sortDate: Date) {
        self.administrationRoute = administrationRoute
        self.customSubstanceName = customSubstanceName
        self.dosesAndUnit = dosesAndUnit
        self.substanceColor = substanceColor
        self.sortDate = sortDate
        self.id = administrationRoute.rawValue + customSubstanceName
    }
}

struct CustomUnitDoseSuggestion: Identifiable, Equatable {
    let id = UUID()
    let dose: Double?
    let isEstimate: Bool
    let estimatedStandardDeviation: Double?

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.dose == rhs.dose && lhs.isEstimate == rhs.isEstimate && lhs.estimatedStandardDeviation == rhs.estimatedStandardDeviation
    }
}
