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
    private let color: SubstanceColor

    private let timelineDrawables: [TimelineDrawable]

    var endRelativeToStartInSeconds: TimeInterval {
        timelineDrawables.map { $0.endOfLineRelativeToStartInSeconds }.max() ?? 0
    }

    // swiftlint:disable function_body_length
    init(
        startGraph: Date,
        color: SubstanceColor,
        roaDuration: RoaDuration?,
        weightedLines: [WeightedLine],
        areRedosesDrawnIndividually: Bool
    ) {
        self.color = color
        guard let roaDuration else {
            timelineDrawables = weightedLines.map { weightedLine in
                NoTimeline(
                    onsetDelayInHours: weightedLine.onsetDelayInHours,
                    ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                )
            }
            return
        }
        if let fullCumulatives = roaDuration.toFullCumulativeTimeline(weightedLines: weightedLines, graphStartTime: startGraph), !areRedosesDrawnIndividually {
            timelineDrawables = [fullCumulatives]
        } else {
            let fulls = weightedLines.compactMap { weightedLine in
                roaDuration.toFullTimeline(
                    peakAndOffsetWeight: weightedLine.horizontalWeight,
                    verticalWeight: weightedLine.height,
                    onsetDelayInHours: weightedLine.onsetDelayInHours,
                    ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                )
            }
            if !fulls.isEmpty, areRedosesDrawnIndividually {
                timelineDrawables = fulls
            } else {
                let onsetComeupPeakTotals = weightedLines.compactMap { weightedLine in
                    roaDuration.toOnsetComeupPeakTotalTimeline(
                        peakAndTotalWeight: weightedLine.horizontalWeight,
                        verticalWeight: weightedLine.height,
                        onsetDelayInHours: weightedLine.onsetDelayInHours,
                        ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                    )
                }
                if !onsetComeupPeakTotals.isEmpty {
                    timelineDrawables = onsetComeupPeakTotals
                } else {
                    let onsetComeupTotals = weightedLines.compactMap { weightedLine in
                        roaDuration.toOnsetComeupTotalTimeline(
                            totalWeight: weightedLine.horizontalWeight,
                            verticalWeight: weightedLine.height,
                            onsetDelayInHours: weightedLine.onsetDelayInHours,
                            ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                        )
                    }
                    if !onsetComeupTotals.isEmpty {
                        timelineDrawables = onsetComeupTotals
                    } else {
                        let onsetTotals = weightedLines.compactMap { weightedLine in
                            roaDuration.toOnsetTotalTimeline(
                                totalWeight: weightedLine.horizontalWeight,
                                verticalWeight: weightedLine.height,
                                onsetDelayInHours: weightedLine.onsetDelayInHours,
                                ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                            )
                        }
                        if !onsetTotals.isEmpty {
                            timelineDrawables = onsetTotals
                        } else {
                            let totals = weightedLines.compactMap { weightedLine in
                                roaDuration.toTotalTimeline(
                                    totalWeight: weightedLine.horizontalWeight,
                                    verticalWeight: weightedLine.height,
                                    onsetDelayInHours: weightedLine.onsetDelayInHours,
                                    ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                                )
                            }
                            if !totals.isEmpty {
                                timelineDrawables = totals
                            } else {
                                let onsetComeupPeaks = weightedLines.compactMap { weightedLine in
                                    roaDuration.toOnsetComeupPeakTimeline(
                                        peakWeight: weightedLine.horizontalWeight,
                                        verticalWeight: weightedLine.height,
                                        onsetDelayInHours: weightedLine.onsetDelayInHours,
                                        ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                                    )
                                }
                                if !onsetComeupPeaks.isEmpty {
                                    timelineDrawables = onsetComeupPeaks
                                } else {
                                    let onsetComeups = weightedLines.compactMap { weightedLine in
                                        roaDuration.toOnsetComeupTimeline(
                                            verticalWeight: weightedLine.height,
                                            onsetDelayInHours: weightedLine.onsetDelayInHours,
                                            ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                                        )
                                    }
                                    if !onsetComeups.isEmpty {
                                        timelineDrawables = onsetComeups
                                    } else {
                                        let onsets = weightedLines.compactMap { weightedLine in
                                            roaDuration.toOnsetTimeline(
                                                onsetDelayInHours: weightedLine.onsetDelayInHours,
                                                ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                                            )
                                        }
                                        if !onsets.isEmpty {
                                            timelineDrawables = onsets
                                        } else {
                                            timelineDrawables = weightedLines.map { weightedLine in
                                                NoTimeline(
                                                    onsetDelayInHours: weightedLine.onsetDelayInHours,
                                                    ingestionTimeRelativeToStartInSeconds: GroupDrawable.getDistanceFromStartGraphInSeconds(graphStartTime: startGraph, time: weightedLine.startTime)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // swiftlint:enable function_body_length

    private static func getDistanceFromStartGraphInSeconds(graphStartTime: Date, time: Date) -> TimeInterval {
        time.timeIntervalSince1970 - graphStartTime.timeIntervalSince1970
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        lineWidth: Double
    ) {
        for drawable in timelineDrawables {
            drawable.draw(
                context: context,
                height: height,
                pixelsPerSec: pixelsPerSec,
                color: color.swiftUIColor,
                lineWidth: lineWidth
            )
        }
    }
}
