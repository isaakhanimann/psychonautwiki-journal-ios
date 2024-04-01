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
import AppIntents

struct OpenLastExperienceIntent: AppIntent {

    static var title: LocalizedStringResource = "Open Last Experience"

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openLatestExperience()
        return .result()
    }

    static var openAppWhenRun: Bool = true
}

struct SearchSubstancesIntent: AppIntent {

    static var title: LocalizedStringResource = "Search Substance"

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.maybeSearchForSubstance()
        return .result()
    }

    static var openAppWhenRun: Bool = true
}

struct AddIngestionIntent: AppIntent {

    static var title: LocalizedStringResource = "Add Ingestion"

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.addIngestion()
        return .result()
    }

    static var openAppWhenRun: Bool = true
}


struct JournalAutoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddIngestionIntent(),
                    phrases: [
                        "Add Ingestion in \(.applicationName)",
                        "New Ingestion in \(.applicationName)",
                        "Log Ingestion in \(.applicationName)",
                        "\(.applicationName) Ingestion",
                    ],
                    shortTitle: "Add Ingestion",
                    systemImageName: "plus"
        )
        AppShortcut(intent: OpenLastExperienceIntent(),
                    phrases: [
                        "Open Last Experience in \(.applicationName)",
                        "Open Experience in \(.applicationName)",
                        "Open Timeline in \(.applicationName)",
                    ],
                    shortTitle: "Open Last Experience",
                    systemImageName: "chart.xyaxis.line"
        )
        AppShortcut(intent: SearchSubstancesIntent(),
                    phrases: [
                        "Search Substances in \(.applicationName)",
                        "Search for Substance in \(.applicationName)",
                        "Search in \(.applicationName)",
                    ],
                    shortTitle: "Search Substance",
                    systemImageName: "magnifyingglass"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .blue
}
