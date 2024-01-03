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

import CoreData
import Foundation

struct RoaDuration: Codable {
    let onset: DurationRange?
    let comeup: DurationRange?
    let peak: DurationRange?
    let offset: DurationRange?
    let total: DurationRange?
    let afterglow: DurationRange?

    var maxLengthOfTimelineInSec: TimeInterval? {
        let total = total?.maxSec
        guard let onset = onset?.maxSec else { return total }
        guard let comeup = comeup?.maxSec else { return total }
        guard let peak = peak?.maxSec else { return total }
        guard let offset = offset?.maxSec else { return total }
        return onset
            + comeup
            + peak
            + offset
    }

    var isFullTimeLineDefined: Bool {
        onset?.isFullyDefined ?? false &&
            comeup?.isFullyDefined ?? false &&
            peak?.isFullyDefined ?? false &&
            offset?.isFullyDefined ?? false
    }
}
