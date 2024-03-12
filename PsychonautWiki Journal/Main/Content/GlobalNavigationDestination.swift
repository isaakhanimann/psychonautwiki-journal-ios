// Copyright (c) 2024. Isaak Hanimann.
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

enum GlobalNavigationDestination: Hashable {
    // substance tab mainly
    case substance(substance: Substance)
    case editCustomSubstance(customSubstance: CustomSubstance)
    case webView(articleURL: URL)
    case webViewInteractions(substanceName: String, articleURL: URL)
    case summary(substanceName: String, summary: String)
    case categories(substance: Substance)
    case dose(substance: Substance)
    case tolerance(substance: Substance)
    case toxicity(substance: Substance)
    case duration(substance: Substance)
    case interactions(interactions: Interactions, substance: Substance)
    case effects(substanceName: String, effect: String)
    case risks(substance: Substance)
    case saferUse(substance: Substance)
    case addiction(substanceName: String, addictionPotential: String)
    case timelineInfo

    // journal tab mainly
    case calendar
    case experience(experience: Experience)
    case chooseExperience(experiences: [Experience])
    case saferHallucinogen
    case allInteractions(substancesToCheck: [Substance])
    case toleranceTexts(substances: [SubstanceWithToleranceAndColor])
    case timeline(timelineModel: TimelineModel)
    case explainExperience

    // stats tab mainly
    case toleranceChart
    case toleranceChartExplanation
    case experienceDetails(experienceData: ExperienceData)
    case substanceDetails(substanceData: SubstanceData)

    // safer tab
    case research
    case testing
    case howToDose
    case setAndSetting
    case saferCombinations
    case saferRoutes
    case allergyTests
    case reflection
    case safetyOfOthers
    case recoveryPosition
    case sprayCalculator
    case testingServices
    case reagentTesting
    case doseGuide
    case doseClassification
    case volumetricDosing
    case administrationRouteInfo

    // settings tab
    case editColors
    case customUnits
    case faq
    case customUnitsArchive
    case shareApp
}
