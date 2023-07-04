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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TimelineView(.everyMinute) { context in
            if numberOfRows < 8 {
                getChart(with: context.date)
                    .frame(height: CGFloat(numberOfRows) * 60)
            } else {
                getChart(with: context.date)
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
            RuleMark(x: .value("Current Time", date))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
    }
}

@available(iOS 16.0, *)
struct ToleranceChart_Previews: PreviewProvider {
    static var previews: some View {
        ToleranceChart(toleranceWindows: ToleranceChartPreviewDataProvider.mock1,
                       numberOfRows: 2)
        .padding(.horizontal)
    }
}
