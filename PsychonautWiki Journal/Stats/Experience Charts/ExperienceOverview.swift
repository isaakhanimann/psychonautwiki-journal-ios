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

struct ExperienceOverviewChart: View {
    let experienceData: ExperienceData

    var body: some View {
        Chart(experienceData.last12Months, id: \.month) {
            BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Experiences", $0.experienceCount)
            )
            .foregroundStyle(by: .value("Substance", $0.substanceName))
        }
        .chartForegroundStyleScale(mapping: experienceData.colorMapping)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct ExperienceOverview: View {
    let experienceData: ExperienceData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Experiences Last 12 Months")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("\(experienceData.last12MonthsTotal, format: .number) Experiences")
                .font(.title2.bold())
            ExperienceOverviewChart(experienceData: experienceData)
                .frame(height: 100)
        }
    }
}

#Preview {
    ExperienceOverview(experienceData: .mock1)
        .padding()
}
