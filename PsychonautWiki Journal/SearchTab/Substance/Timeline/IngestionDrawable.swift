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
    let timelineDrawable: TimelineDrawable
    var insetTimes = 0

    init(startGraph: Date, color: Color, ingestionTime: Date, roaDuration: RoaDuration?, verticalWeight: Double = 1, horizontalWeight: Double = 0.5) {
        self.distanceFromStart = ingestionTime.timeIntervalSinceReferenceDate - startGraph.timeIntervalSinceReferenceDate
        self.color = color
        self.ingestionTime = ingestionTime
        self.roaDuration = roaDuration
        self.verticalWeight = verticalWeight
        self.horizontalWeight = horizontalWeight
        if let full = roaDuration?.toFullTimeline(peakAndOffsetWeight: horizontalWeight) {
            self.timelineDrawable = full
        } else if let onsetComeupPeakTotal = roaDuration?.toOnsetComeupPeakTotalTimeline(peakAndTotalWeight: horizontalWeight) {
            self.timelineDrawable = onsetComeupPeakTotal
        } else if let onsetComeupPeakTotal = roaDuration?.toOnsetComeupPeakTotalTimeline(peakAndTotalWeight: horizontalWeight) {
            self.timelineDrawable = onsetComeupPeakTotal
        } else if let onsetComeupTotal = roaDuration?.toOnsetComeupTotalTimeline(totalWeight: horizontalWeight) {
            self.timelineDrawable = onsetComeupTotal
        } else if let onsetTotal = roaDuration?.toOnsetTotalTimeline(totalWeight: horizontalWeight) {
            self.timelineDrawable = onsetTotal
        } else if let onsetComeup = roaDuration?.toOnsetComeupTimeline() {
            self.timelineDrawable = onsetComeup
        } else if let onsetComeupPeak = roaDuration?.toOnsetComeupPeakTimeline(peakWeight: horizontalWeight) {
            self.timelineDrawable = onsetComeupPeak
        } else if let onset = roaDuration?.toOnsetTimeline() {
            self.timelineDrawable = onset
        } else {
            self.timelineDrawable = NoTimeline()
        }
    }
}
