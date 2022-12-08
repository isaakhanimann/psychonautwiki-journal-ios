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
        let twoHours: TimeInterval = 2 * 60 * 60
        let maxWidth: TimeInterval = drawablesWithoutInsets.map({ draw in
            draw.distanceFromStart + (draw.timelineDrawable?.width ?? twoHours)
        }).max() ?? twoHours
        self.totalWidth = maxWidth
        self.axisDrawable = AxisDrawable(startTime: startTime, widthInSeconds: maxWidth)
    }
}
