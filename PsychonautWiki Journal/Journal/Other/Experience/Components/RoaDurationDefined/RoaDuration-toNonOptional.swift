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

extension RoaDuration {
    func toNonOptional() -> NonOptional? {
        if let onsetUnwrap = onset?.maybeFullDurationRange {
            if let comeupUnwrap = comeup?.maybeFullDurationRange {
                if let peakUnwrap = peak?.maybeFullDurationRange {
                    if let offsetUnwrap = offset?.maybeFullDurationRange {
                        return RoaDurationFull(
                            onset: onsetUnwrap,
                            comeup: comeupUnwrap,
                            peak: peakUnwrap,
                            offset: offsetUnwrap)
                    } else {
                        if let totalUnwrap = total?.maybeFullDurationRange {
                            return RoaDurationOnsetComeupPeakTotal(
                                onset: onsetUnwrap,
                                comeup: comeupUnwrap,
                                peak: peakUnwrap,
                                total: totalUnwrap)
                        } else {
                            return RoaDurationOnsetComeupPeak(
                                onset: onsetUnwrap,
                                comeup: comeupUnwrap,
                                peak: peakUnwrap)
                        }
                    }
                } else {
                    if let totalUnwrap = total?.maybeFullDurationRange {
                        return RoaDurationOnsetComeupTotal(
                            onset: onsetUnwrap,
                            comeup: comeupUnwrap,
                            total: totalUnwrap)
                    } else {
                        return RoaDurationOnsetComeup(
                            onset: onsetUnwrap,
                            comeup: comeupUnwrap)
                    }
                }
            } else {
                if let totalUnwrap = total?.maybeFullDurationRange {
                    return RoaDurationOnsetTotal(
                        onset: onsetUnwrap,
                        total: totalUnwrap)
                } else {
                    return RoaDurationOnset(onset: onsetUnwrap)
                }
            }
        } else {
            if let totalUnwrap = total?.maybeFullDurationRange {
                return RoaDurationTotal(total: totalUnwrap)
            } else {
                return nil
            }
        }
    }
}
