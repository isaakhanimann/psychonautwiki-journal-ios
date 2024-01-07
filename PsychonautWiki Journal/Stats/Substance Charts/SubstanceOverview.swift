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

import Charts
import SwiftUI

struct SubstanceOverviewChart: View {
    let substanceData: SubstanceData

    var body: some View {
        Chart(substanceData.last12Months) { element in
            BarMark(
                x: .value("Experiences", element.experienceCount),
                y: .value("Substance", element.substanceName)
            )
            .foregroundStyle(by: .value("Substance", element.substanceName))
            .opacity(element.substanceName == substanceData.last12Months.first?.substanceName ? 1 : 0.5)
        }
        .chartForegroundStyleScale(mapping: substanceData.colorMapping)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct SubstanceOverview: View {
    let substanceData: SubstanceData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Experiences Last 12 Months")
                .foregroundStyle(.secondary)
            if let mostUsedName = substanceData.last12Months.first?.substanceName {
                Text(mostUsedName)
                    .font(.title2.bold())
            } else {
                Text("None")
                    .font(.title2.bold())
            }
            SubstanceOverviewChart(substanceData: substanceData)
                .frame(height: chartHeight)
        }
    }

    var chartHeight: CGFloat {
        let numberOfRows = substanceData.last12Months.count
        if numberOfRows < 5 {
            return CGFloat(numberOfRows * 20)
        } else {
            return 100
        }
    }
}

#Preview {
    SubstanceOverview(substanceData: .mock1)
        .padding()
}
