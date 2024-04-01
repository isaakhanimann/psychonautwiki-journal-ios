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

class Navigator: ObservableObject {

    static let shared = Navigator()

    @Published var statsTabPath = NavigationPath()
    @Published var journalTabPath = NavigationPath()
    @Published var substancesTabPath = NavigationPath()
    @Published var saferTabPath = NavigationPath()
    @Published var settingsTabPath = NavigationPath()

    @Published var isShowingAddIngestionSheet = false

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
        showAddIngestionFullScreenCover()
    }

    func showAddIngestionFullScreenCover() {
        isShowingAddIngestionSheet.toggle()
    }
}
