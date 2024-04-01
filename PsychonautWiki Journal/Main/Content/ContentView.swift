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
    @AppStorage(PersistenceController.isEyeOpenKey1) var isEyeOpen1: Bool = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen2: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false
    @AppStorage("hasBeenMigrated3") var hasBeenMigrated3: Bool = false
    @AppStorage("hasBeenMigrated4") var hasBeenMigrated4: Bool = false

    var body: some View {
        ContentScreen(isEyeOpen: isEyeOpen2)
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

enum Tab {
    case stats
    case journal
    case substances
    case safer
    case settings
}

class Navigator: ObservableObject {

    static let shared = Navigator()

    @Published var statsTabPath = NavigationPath()
    @Published var journalTabPath = NavigationPath()
    @Published var substancesTabPath = NavigationPath()
    @Published var saferTabPath = NavigationPath()
    @Published var settingsTabPath = NavigationPath()



    @Published var selectedTab: Tab = .journal

    @Published var isSearchFocused: Bool = false
    @Published var searchText = ""
    @Published var selectedCategories: [String] = []

    func clearCategories() {
        selectedCategories.removeAll()
    }

    var binding: Binding<Tab> {
        Binding {
            self.selectedTab
        } set: { newValue in
            if self.selectedTab == newValue {
                switch newValue {
                case .stats:
                    if !self.statsTabPath.isEmpty {
                        self.statsTabPath.removeLast()
                    }
                case .journal:
                    if !self.journalTabPath.isEmpty {
                        self.journalTabPath.removeLast()
                    }
                case .substances:
                    if !self.substancesTabPath.isEmpty {
                        self.substancesTabPath.removeLast()
                    } else {
                        self.searchText = ""
                        self.clearCategories()
                        self.isSearchFocused = true
                    }
                case .safer:
                    if !self.saferTabPath.isEmpty {
                        self.saferTabPath.removeLast()
                    }
                case .settings:
                    if !self.settingsTabPath.isEmpty {
                        self.settingsTabPath.removeLast()
                    }
                }
            }
            self.selectedTab = newValue
        }
    }

    func openLatestActiveExperience() {
        selectedTab = .journal
        if let latestActiveExperience = PersistenceController.shared.getLatestActiveExperience() {
            journalTabPath.removeLast(journalTabPath.count)
            journalTabPath.append(GlobalNavigationDestination.experience(experience: latestActiveExperience))
        }
    }

    func openLatestExperience() {
        selectedTab = .journal
        if let latestExperience = PersistenceController.shared.getLatestExperience() {
            journalTabPath.removeLast(journalTabPath.count)
            journalTabPath.append(GlobalNavigationDestination.experience(experience: latestExperience))
        }
    }

    func maybeSearchForSubstance() {
        selectedTab = .substances
        let isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2)
        if isEyeOpen {
            substancesTabPath.removeLast(substancesTabPath.count)
            clearCategories()
            searchText = ""
            isSearchFocused = true
        }
    }

    func addIngestion() {
        selectedTab = .journal
        journalTabPath.removeLast(journalTabPath.count)
        // todo show fullscreencover
    }
}

struct ContentScreen: View {
    let isEyeOpen: Bool

    @ObservedObject var navigator = Navigator.shared
    @FocusState var isSearchFocused: Bool

    var body: some View {
        if isEyeOpen {
            TabView(selection: navigator.binding) {
                statsTab

                journalTab

                NavigationStack(path: $navigator.substancesTabPath) {
                    SearchScreen(
                        isSearchFocused: _isSearchFocused,
                        searchText: $navigator.searchText,
                        selectedCategories: $navigator.selectedCategories,
                        clearCategories: navigator.clearCategories)
                    .onAppear { self.isSearchFocused = navigator.isSearchFocused}
                    .onChange(of: isSearchFocused) { navigator.isSearchFocused = $0 }
                    .onChange(of: navigator.isSearchFocused) { isSearchFocused = $0 }
                    .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                        getScreen(from: destination)
                    }
                }
                .tabItem {
                    Label("Substances", systemImage: "pills")
                }
                .tag(Tab.substances)

                NavigationStack(path: $navigator.saferTabPath) {
                    SaferScreen()
                        .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                            getScreen(from: destination)
                        }
                }
                .tabItem {
                    Label("Safer", systemImage: "cross.case")
                }
                .tag(Tab.safer)

                settingsTab
            }
            .onOpenURL { url in
                if url.absoluteString == openLatestExperience {
                    navigator.openLatestActiveExperience()
                }
            }
        } else {
            TabView(selection: navigator.binding) {
                statsTab
                journalTab
                settingsTab
            }
        }
    }

    var statsTab: some View {
        NavigationStack(path: $navigator.statsTabPath) {
            StatsScreen()
                .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                    getScreen(from: destination)
                }
        }
        .tabItem {
            Label("Stats", systemImage: "chart.bar")
        }
        .tag(Tab.stats)
    }

    var journalTab: some View {
        NavigationStack(path: $navigator.journalTabPath) {
            JournalScreen()
                .navigationDestination(for: GlobalNavigationDestination.self) { destination in
                    getScreen(from: destination)
                }
        }
        .tabItem {
            Label("Journal", systemImage: "square.stack")
        }
        .tag(Tab.journal)
    }

    var settingsTab: some View {
        NavigationStack(path: $navigator.settingsTabPath) {
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
