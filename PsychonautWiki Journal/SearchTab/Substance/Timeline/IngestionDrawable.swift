//
//  IngestionDrawable.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct IngestionDrawable {
    let color: Color
    let ingestionTime: Date
    let roaDuration: RoaDuration?
    let verticalWeight: Double
    let horizontalWeight: Double
    let distanceFromStart: TimeInterval
    let timelineDrawable: TimelineDrawable?
    var insetTimes = 0

    init(startGraph: Date, color: Color, ingestionTime: Date, roaDuration: RoaDuration?, verticalWeight: Double = 1, horizontalWeight: Double = 0.5) {
        self.distanceFromStart = ingestionTime.timeIntervalSinceReferenceDate - startGraph.timeIntervalSinceReferenceDate
        self.color = color
        self.ingestionTime = ingestionTime
        self.roaDuration = roaDuration
        self.verticalWeight = verticalWeight
        self.horizontalWeight = horizontalWeight
        self.timelineDrawable = roaDuration?.toFullTimeline(peakAndOffsetWeight: horizontalWeight)
        ?? roaDuration?.toOnsetComeupPeakTotalTimeline(peakAndTotalWeight: horizontalWeight)
        ?? roaDuration?.toOnsetComeupTotalTimeline(totalWeight: horizontalWeight)
        ?? roaDuration?.toOnsetTotalTimeline(totalWeight: horizontalWeight)
        ?? roaDuration?.toTotalTimeline(totalWeight: horizontalWeight)
    }
}
