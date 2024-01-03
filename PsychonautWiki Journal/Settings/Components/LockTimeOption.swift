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

enum LockTimeOption: String, Identifiable, CaseIterable {
    case immediately
    case after5Minutes
    case after10Minutes
    case after30Minutes
    case after1Hour

    var id: LockTimeOption {
        self
    }

    var timeInterval: TimeInterval {
        switch self {
        case .immediately:
            return 0
        case .after5Minutes:
            return 5 * 60
        case .after10Minutes:
            return 10 * 60
        case .after30Minutes:
            return 30 * 60
        case .after1Hour:
            return 60 * 60
        }
    }

    var text: String {
        switch self {
        case .immediately:
            return "Immediately"
        case .after5Minutes:
            return "After 5 minutes"
        case .after10Minutes:
            return "After 10 minutes"
        case .after30Minutes:
            return "After 30 minutes"
        case .after1Hour:
            return "After 1 hour"
        }
    }
}
