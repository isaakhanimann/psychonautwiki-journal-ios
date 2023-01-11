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

@available(iOS 16, *)
struct IngestionOverviewChart: View {

    let ingestionData: IngestionData

    var body: some View {
        Chart(ingestionData.last12Months) { element in
            BarMark(
                x: .value("Ingestions", element.ingestionCount),
                y: .value("Substance", element.substanceName)
            )
            .foregroundStyle(by: .value("Substance", element.substanceName))
            .opacity(element.substanceName == ingestionData.last12Months.first?.substanceName ? 1 : 0.5)
        }
        .chartForegroundStyleScale(mapping: ingestionData.colorMapping)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

@available(iOS 16, *)
struct IngestionOverview: View {

    let ingestionData: IngestionData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Used Substance Last 12 Months")
                .foregroundStyle(.secondary)
            if let mostUsedName = ingestionData.last12Months.first?.substanceName {
                Text(mostUsedName)
                    .font(.title2.bold())
            } else {
                Text("None")
                    .font(.title2.bold())
            }
            IngestionOverviewChart(ingestionData: ingestionData)
                .frame(height: 100)
        }
    }
}

@available(iOS 16, *)
struct IngestionOverview_Previews: PreviewProvider {
    static var previews: some View {
        IngestionOverview(ingestionData: .mock1)
            .padding()
    }
}
