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

struct GroupDrawable {

    let color: SubstanceColor

    private let timelineDrawables: [TimelineDrawable]

    var endRelativeToStartInSeconds: TimeInterval {
        timelineDrawables.map({$0.endOfLineRelativeToStartInSeconds}).max() ?? 0
    }

    init(
        startGraph: Date,
        color: SubstanceColor,
        roaDuration: RoaDuration?,
        weightedLines: [WeightedLine]
    ) {
        self.color = color
        if let fulls = roaDuration?.toFullTimelines(weightedLines: weightedLines, graphStartTime: startGraph) {
            timelineDrawables = [fulls]
        } else {
            timelineDrawables = []
        }
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        lineWidth: Double) {
            for drawable in timelineDrawables {
                drawable.draw(
                    context: context,
                    height: height,
                    pixelsPerSec: pixelsPerSec,
                    color: color.swiftUIColor,
                    lineWidth: lineWidth)
            }
    }
}
