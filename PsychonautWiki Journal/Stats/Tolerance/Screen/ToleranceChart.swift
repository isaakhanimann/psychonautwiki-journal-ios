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

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct ToleranceChart: View {
    
    let toleranceWindows: [ToleranceWindow]
    let numberOfRows: Int
    let timeOption: ToleranceTimeOption
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if toleranceWindows.isEmpty {
                Text("No ingestions with tolerance info")
                    .foregroundColor(.secondary)
            } else {
                TimelineView(.everyMinute) { context in
                    getChart(with: context.date)
                        .frame(height: CGFloat(numberOfRows) * 60)
                }
            }
        }
    }

    func getChart(with date: Date) -> some View {
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
            case .alwaysShow:
                currentTimeRuleMark
            }
        }
    }

    var currentTimeRuleMark: some ChartContent {
        RuleMark(x: .value("Current Time", Date.now))
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

@available(iOS 16.0, *)
struct ToleranceChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToleranceChart(
                toleranceWindows: ToleranceChartPreviewDataProvider.mock1,
                numberOfRows: 2,
                timeOption: .alwaysShow
            )
            .padding(.horizontal)
            ToleranceChart(
                toleranceWindows: [],
                numberOfRows: 0,
                timeOption: .alwaysShow
            )
            .padding(.horizontal)
        }
    }
}
