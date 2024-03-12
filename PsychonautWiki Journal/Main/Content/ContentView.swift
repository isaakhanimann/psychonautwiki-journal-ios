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

import AlertToast
import SwiftUI

struct ContentView: View {
    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey1) var isEyeOpen1: Bool = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen2: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false
    @AppStorage("hasBeenMigrated3") var hasBeenMigrated3: Bool = false
    @AppStorage("hasBeenMigrated4") var hasBeenMigrated4: Bool = false

    var body: some View {
        ContentScreen(isEyeOpen: isEyeOpen2)
            .onOpenURL { _ in
                if !UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2) {
                    UserDefaults.standard.set(true, forKey: PersistenceController.isEyeOpenKey2)
                    toastViewModel.showSuccessToast(message: "Unlocked")
                } else {
                    toastViewModel.showSuccessToast(message: "Already Unlocked")
                }
            }
            .toast(isPresenting: $toastViewModel.isShowingToast) {
                AlertToast(
                    displayMode: .alert,
                    type: toastViewModel.isSuccessToast ? .complete(.green) : .error(.red),
                    title: toastViewModel.toastMessage
                )
            }
            .fullScreenCover(isPresented: $needsToSeeWelcome) {
                WelcomeScreen(isShowingWelcome: $needsToSeeWelcome)
            }
            .onAppear {
                if !hasBeenMigrated2 {
                    PersistenceController.shared.migrateCompanionsAndExperienceSortDates()
                    hasBeenMigrated2 = true
                    isEyeOpen2 = isEyeOpen1
                }
                if !hasBeenMigrated3 {
                    PersistenceController.shared.migrateIngestionNamesAndUnits()
                    hasBeenMigrated3 = true
                }
                if !hasBeenMigrated4 {
                    PersistenceController.shared.migrateColors()
                    hasBeenMigrated4 = true
                }
            }
    }
}

struct ContentScreen: View {
    let isEyeOpen: Bool

    @State private var statsTabPath = NavigationPath()
    @State private var journalTabPath = NavigationPath()
    @State private var substancesTabPath = NavigationPath()
    @State private var saferTabPath = NavigationPath()
    @State private var settingsTabPath = NavigationPath()

    enum Tab {
        case stats
        case journal
        case substances
        case safer
        case settings
    }

    @State private var selectedTab: Tab = .journal

    @FocusState private var isSearchFocused: Bool
    @State private var searchText = ""
    @State private var selectedCategories: [String] = []

    func clearCategories() {
        selectedCategories.removeAll()
    }

    var body: some View {
        let binding = Binding {
            selectedTab
        } set: { newValue in
            if selectedTab == newValue {
                switch newValue {
                case .stats:
                    if !statsTabPath.isEmpty {
                        statsTabPath.removeLast()
                    }
                case .journal:
                    if !journalTabPath.isEmpty {
                        journalTabPath.removeLast()
                    }
                case .substances:
                    if !substancesTabPath.isEmpty {
                        substancesTabPath.removeLast()
                    } else {
                        searchText = ""
                        clearCategories()
                        isSearchFocused = true
                    }
                case .safer:
                    if !saferTabPath.isEmpty {
                        saferTabPath.removeLast()
                    }
                case .settings:
                    if !settingsTabPath.isEmpty {
                        settingsTabPath.removeLast()
                    }
                }
            }
            selectedTab = newValue
        }
        TabView(selection: binding) {
            NavigationStack(path: $statsTabPath) {
                StatsScreen()
                    .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                        getScreen(from: destination)
                    }
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            .tag(Tab.stats)
            NavigationStack(path: $journalTabPath) {
                JournalScreen()
                    .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                        getScreen(from: destination)
                    }
            }
            .tabItem {
                Label("Journal", systemImage: "square.stack")
            }
            .tag(Tab.journal)
            if isEyeOpen {
                NavigationStack(path: $substancesTabPath) {
                    SearchScreen(
                        isSearchFocused: _isSearchFocused,
                        searchText: $searchText,
                        selectedCategories: $selectedCategories,
                        clearCategories: clearCategories)
                    .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                        getScreen(from: destination)
                    }
                }
                .tabItem {
                    Label("Substances", systemImage: "magnifyingglass")
                }
                .tag(Tab.substances)
                NavigationStack(path: $saferTabPath) {
                    SaferScreen()
                        .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                            getScreen(from: destination)
                        }
                }
                .tabItem {
                    Label("Safer", systemImage: "cross.case")
                }
                .tag(Tab.safer)
            }
            NavigationStack(path: $settingsTabPath) {
                SettingsScreen()
                    .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                        getScreen(from: destination)
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
    }
}

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
        case let .summary(substanceName, summary):
            SummaryScreen(substanceName: substanceName, summary: summary)
        case let .categories(substance):
            CategoryScreen(substance: substance)
        case let .dose(substance):
            DosesScreen(substance: substance)
        case let .tolerance(substance):
            ToleranceScreen(substance: substance)
        case let .toxicity(substance):
            ToxicityScreen(substance: substance)
        case let .duration(substance):
            DurationScreen(substance: substance)
        case let .interactions(interactions, substance):
            InteractionsScreen(
                interactions: interactions,
                substance: substance
            )
        case let .effects(substanceName, effect):
            EffectScreen(substanceName: substanceName, effect: effect)
        case let .risks(substance):
            RiskScreen(substance: substance)
        case let .saferUse(substance):
            SaferUseScreen(substance: substance)
        case let .addiction(substanceName, addictionPotential):
            AddictionScreen(
                substanceName: substanceName,
                addictionPotential: addictionPotential
            )
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
        case .research:
            List {
                Text("In advance research the duration, subjective effects and potential adverse effects which the substance or combination of substances are likely to produce.\nRead the info in here and also the PsychonautWiki article. Its best to cross-reference with other sources (Tripsit, Erowid, Wikipedia, Bluelight, Reddit, etc).\nThere is no rush.")
            }
            .navigationTitle("Research")
        case .testing:
            TestingScreen()
        case .howToDose:
            HowToDoseScreen()
        case .setAndSetting:
            SetAndSettingScreen()
        case .saferCombinations:
            SaferCombinationsScreen()
        case .saferRoutes:
            SaferRoutesScreen()
        case .allergyTests:
            List {
                Text("Simply dose a minuscule amount of the substance (e.g. 1/10 to 1/4 of a regular dose) and wait several hours to verify that you do not exhibit an unusual or idiosyncratic response.")
            }
            .navigationTitle("Allergy Tests")
        case .reflection:
            List {
                Text("Carefully monitor the frequency and intensity of any substance use to ensure it is not sliding into abuse and addiction. In particular, many stimulants, opioids, and depressants are known to be highly addictive.")
            }
            .navigationTitle("Reflection")
        case .safetyOfOthers:
            List {
                Text("Don’t drive, operate heavy machinery, or otherwise be directly or indirectly responsible for the safety or care of another person while intoxicated.")
            }
            .navigationTitle("Safety of Others")
        case .recoveryPosition:
            List {
                Text("If someone is unconscious and breathing place them into Recovery Position to prevent death by the suffocation of vomit after a drug overdose.\nHave the contact details of help services to hand in case of urgent need.")
                Link(destination: URL(string: "https://www.youtube.com/watch?v=dv3agW-DZ5I")!
                ) {
                    Label("Recovery Position Video", systemImage: "play")
                }
            }
            .navigationTitle("Recovery Position")
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
        }
    }
}
