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

import Charts
import SwiftUI

struct ToleranceChart: View {
    let toleranceWindows: [ToleranceWindow]
    let numberOfRows: Int
    let timeOption: ToleranceTimeOption
    let experienceStartDate: Date?
    let isTimeRelative: Bool

    @Environment(\.colorScheme) var colorScheme

    private var chartHeight: CGFloat {
        if numberOfRows < 4 {
            return CGFloat(numberOfRows) * 55
        } else if numberOfRows < 7 {
            return CGFloat(numberOfRows) * 50
        } else {
            return CGFloat(numberOfRows) * 45
        }
    }

    var body: some View {
        Group {
            if toleranceWindows.isEmpty {
                Text("No ingestions with tolerance info")
                    .foregroundColor(.secondary)
            } else {
                TimelineView(.everyMinute) { context in
                    getChart(with: context.date)
                        .frame(height: chartHeight)
                }
            }
        }
    }

    @State private var fingerPosition: CGPoint?

    func getChart(with _: Date) -> some View {
        Chart {
            ForEach(toleranceWindows) { window in
                BarMark(
                    xStart: .value("Start Time", window.start),
                    xEnd: .value("End Time", window.end),
                    y: .value("Substance", window.substanceName)
                )
                .foregroundStyle(window.barColor)
            }
            switch timeOption {
            case .onlyIfCurrentTimeInChart:
                if isCurrentTimeInChart {
                    currentTimeRuleMark
                }
                if let experienceStartDate, fabs(experienceStartDate.timeIntervalSinceNow) > 24 * 60 * 60 {
                    RuleMark(x: .value("Experience Time", experienceStartDate))
                        .foregroundStyle(Color.gray)
                }
            case .alwaysShow:
                currentTimeRuleMark
            }
        }
        .chartOverlay { proxy in
            ZStack {
                GeometryReader { geometryProxy in
                    if let fingerPosition {
                        let relativeXPosition = fingerPosition.x - geometryProxy[proxy.plotAreaFrame].origin.x
                        if let dateAtFinger = proxy.value(atX: relativeXPosition) as Date? {
                            let lineHeight = geometryProxy[proxy.plotAreaFrame].maxY
                            Rectangle()
                                .fill(.foreground)
                                .frame(width: 2, height: lineHeight)
                                .position(x: fingerPosition.x, y: lineHeight / 2)
                            let potentialDateY = fingerPosition.y - 120
                            let minDateY = potentialDateY > 0 ? potentialDateY : 0
                            let dateY = minDateY > lineHeight ? lineHeight : minDateY
                            HStack {
                                Spacer()
                                Group {
                                    if isTimeRelative {
                                        if dateAtFinger > .now {
                                            let durationText = Text(DateDifference.formattedWithAtLeastDaysBetween(.now, and: dateAtFinger))
                                            Text("in ") + durationText
                                        } else {
                                            let durationText = Text(DateDifference.formattedWithAtLeastDaysBetween(dateAtFinger, and: .now))
                                            durationText + Text(" ago")
                                        }
                                    } else {
                                        Text(dateAtFinger, style: .date)
                                    }
                                }
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(uiColor: .systemGray6))
                                    }
                                }
                                Spacer()
                            }
                            .offset(y: dateY)
                        }
                    }
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: minimumDistanceForDetectingDragGesture)
                                .onChanged({ value in
                                    fingerPosition = value.location
                                })
                                .onEnded { value in
                                    fingerPosition = nil
                                }
                        )
                }
            }
        }
    }

    var currentTimeRuleMark: some ChartContent {
        RuleMark(x: .value("Current Time", Date.now.getDateWithoutTime()))
            .foregroundStyle(colorScheme == .dark ? .white : .black)
    }

    var isCurrentTimeInChart: Bool {
        let starts = toleranceWindows.map { $0.start }
        let ends = toleranceWindows.map { $0.end }
        if let startChart = starts.min(),
           let endChart = ends.max(),
           startChart <= Date.now && Date.now <= endChart {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    Group {
        ToleranceChart(
            toleranceWindows: ToleranceChartPreviewDataProvider.mock1,
            numberOfRows: 2,
            timeOption: .alwaysShow,
            experienceStartDate: nil,
            isTimeRelative: true
        )
        .padding(.horizontal)
        ToleranceChart(
            toleranceWindows: [],
            numberOfRows: 0,
            timeOption: .alwaysShow,
            experienceStartDate: nil,
            isTimeRelative: false
        )
        .padding(.horizontal)
    }
}
