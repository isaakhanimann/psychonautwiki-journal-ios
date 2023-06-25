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

import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey1) var isEyeOpen1: Bool = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen2: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false
    @AppStorage("hasBeenMigrated3") var hasBeenMigrated3: Bool = false
    @State private var isShowingJournal = true

    var body: some View {
        ContentScreen(isEyeOpen: isEyeOpen2)
            .onOpenURL { url in
                if url.absoluteString == OpenJournalURL {
                    isShowingJournal = true
                } else {
                    if !UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2) {
                        UserDefaults.standard.set(true, forKey: PersistenceController.isEyeOpenKey2)
                        toastViewModel.showSuccessToast(message: "Unlocked")
                    } else {
                        toastViewModel.showSuccessToast(message: "Already Unlocked")
                    }
                }
            }
            .toast(isPresenting: $toastViewModel.isShowingToast) {
                AlertToast(
                    displayMode: .alert,
                    type: toastViewModel.isSuccessToast ? .complete(.green): .error(.red),
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
            }
    }
}

enum Tab {
    case stats, journal, substances, safer, settings
}

struct ContentScreen: View {
    let isEyeOpen: Bool

    @StateObject private var tabBarObserver = TabBarObserver()

    var body: some View {
        TabView(selection: $tabBarObserver.selectedTab) {
            if #available(iOS 16, *) {
                StatsScreen()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
                    .tag(Tab.stats)
            }
            JournalScreen()
                .tabItem {
                    Label("Journal", systemImage: "square.stack")
                }
                .tag(Tab.journal)
            if isEyeOpen {
                SearchScreen()
                    .tabItem {
                        Label("Substances", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.substances)
                SaferScreen()
                    .tabItem {
                        Label("Safer", systemImage: "cross.case")
                    }
                    .tag(Tab.safer)
            }
            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }.environmentObject(tabBarObserver)
    }
}
