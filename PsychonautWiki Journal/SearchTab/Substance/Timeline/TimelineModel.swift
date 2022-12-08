//
//  TimelineModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.12.22.
//

import Foundation
import SwiftUI

struct TimelineModel {
    let startTime: Date
    let totalWidth: TimeInterval
    let ingestionDrawables: [IngestionDrawable]
    let axisDrawable: AxisDrawable

    init(everythingForEachLine: [EverythingForOneLine]) {
        let startTime = everythingForEachLine.map({ one in
            one.startTime
        }).min() ?? Date()
        self.startTime = startTime
        let drawablesWithoutInsets = everythingForEachLine.map { one in
            IngestionDrawable(
                startGraph: startTime,
                color: one.color,
                ingestionTime: one.startTime,
                roaDuration: one.roaDuration,
                verticalWeight: one.verticalWeight,
                horizontalWeight: one.horizontalWeight
            )
        }
        self.ingestionDrawables = drawablesWithoutInsets
        let sumWidth = drawablesWithoutInsets.map({ draw in
            draw.timelineDrawable?.width ?? 2 * 60 * 60
        }).reduce(0, +)
        self.totalWidth = sumWidth
        self.axisDrawable = AxisDrawable(startTime: startTime, widthInSeconds: sumWidth)
    }
}
