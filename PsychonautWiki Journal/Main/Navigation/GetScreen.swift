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

import SwiftUI

func getScreen(from destination: GlobalNavigationDestination) -> some View {
    Group {
        switch destination {
        case let .editCustomSubstance(customSubstance):
            EditCustomSubstanceView(customSubstance: customSubstance)
        case let .substance(substance):
            SubstanceScreen(substance: substance)
        case let .webView(articleURL):
            WebViewScreen(articleURL: articleURL)
        case let .webViewInteractions(substanceName, interactionURL):
            WebViewScreen(articleURL: interactionURL)
                .navigationTitle("\(substanceName) Interactions")
        case let .dose(substance):
            List {
                DosesSection(substance: substance)
            }.navigationTitle("\(substance.name) Dosage")
        case .timelineInfo:
            List {
                TimelineExplanationTexts()
            }.navigationTitle("Timeline Info")
        case .calendar:
            JournalCalendarScreen()
        case let .experience(experience):
            ExperienceScreen(experience: experience)
        case let .chooseExperience(experiences):
            List(experiences) { experience in
                ExperienceRow(experience: experience, isTimeRelative: false)
            }
        case .saferHallucinogen:
            SaferHallucinogenScreen()
        case let .allInteractions(substancesToCheck):
            GoThroughAllInteractionsScreen(substancesToCheck: substancesToCheck)
        case let .toleranceTexts(substances):
            ToleranceTextsScreen(substances: substances)
        case .toleranceChartExplanation:
            ToleranceChartExplanationScreen()
        case .toleranceChart:
            ToleranceChartScreen()
        case let .experienceDetails(experienceData):
            ExperienceDetailsScreen(experienceData: experienceData)
        case let .substanceDetails(substanceData):
            SubstanceDetailsScreen(substanceData: substanceData)
        case .saferRoutes:
            SaferRoutesScreen()
        case .sprayCalculator:
            SprayCalculatorScreen()
        case .testingServices:
            TestingServicesScreen()
        case .reagentTesting:
            ReagentTestingScreen()
        case .doseGuide:
            DosageGuideScreen()
        case .doseClassification:
            DosageClassificationScreen()
        case .volumetricDosing:
            VolumetricDosingScreen()
        case .administrationRouteInfo:
            AdministrationRouteScreen()
        case .editColors:
            EditColorsScreen()
        case .customUnits:
            CustomUnitsScreen()
        case .faq:
            FAQView()
        case .customUnitsArchive:
            CustomUnitsArchiveScreen()
        case .shareApp:
            ShareScreen()
        case let .timeline(timelineModel, timeDisplayStyle):
            TimelineScreen(timelineModel: timelineModel, timeDisplayStyle: timeDisplayStyle)
        case .explainExperience:
            ExplainExperienceSectionScreen()
        case let .dosageStat(substanceName):
            DosageStatScreen(substanceName: substanceName)
        }
    }
}

