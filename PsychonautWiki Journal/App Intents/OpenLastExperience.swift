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

struct OpenLastExperience: AppIntent {

    static var title: LocalizedStringResource = "Open Last Experience"

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openLatestExperience()
        return .result()
    }

    static var openAppWhenRun: Bool = true
}

struct LibraryAutoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: OpenLastExperience(),
                    phrases: ["Open Last Experience in \(.applicationName)"],
                    shortTitle: "Open Last Experience",
                    systemImageName: "chart.xyaxis.line"
        )
    }
}
