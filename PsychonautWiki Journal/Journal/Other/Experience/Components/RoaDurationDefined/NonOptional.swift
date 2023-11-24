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

protocol NonOptional {}

struct RoaDurationFull: NonOptional {
    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let offset: FullDurationRange
}

struct RoaDurationOnsetComeupPeakTotal: NonOptional {
    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let total: FullDurationRange
}

struct RoaDurationOnsetComeupPeak: NonOptional {
    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
}

struct RoaDurationOnsetComeupTotal: NonOptional {
    let onset: FullDurationRange
    let comeup: FullDurationRange
    let total: FullDurationRange
}

struct RoaDurationOnsetComeup: NonOptional {
    let onset: FullDurationRange
    let comeup: FullDurationRange
}

struct RoaDurationOnsetTotal: NonOptional {
    let onset: FullDurationRange
    let total: FullDurationRange
}


struct RoaDurationOnset: NonOptional {
    let onset: FullDurationRange
}

struct RoaDurationTotal: NonOptional {
    let total: FullDurationRange
}
