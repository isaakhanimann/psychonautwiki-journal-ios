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
struct IngestionDetailsChart: View {

    let data: [IngestionCount]
    let colorMapping: (String) -> Color

    var body: some View {
        Chart(data) { element in
            BarMark(
                x: .value("Ingestions", element.ingestionCount),
                y: .value("Substance", element.substanceName)
            )
            .foregroundStyle(by: .value("Substance", element.substanceName))
        }
        .chartForegroundStyleScale(mapping: colorMapping)
        .chartLegend(.hidden)
        .chartXAxisLabel("Ingestion Count")
    }
}

@available(iOS 16, *)
struct IngestionDetails: View {

    let ingestionData: IngestionData
    @State private var timeRange: TimeRange = .last12Months

    var data: [IngestionCount] {
        switch timeRange {
        case .last30Days:
            return ingestionData.last30Days
        case .last12Months:
            return ingestionData.last12Months
        case .years:
            return ingestionData.years
        }
    }

    var body: some View {
        List {
            VStack(alignment: .leading) {
                TimeRangePicker(value: $timeRange)
                    .padding(.bottom)
                Text("Most Used Substance")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text(data.first?.substanceName ?? "None")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                IngestionDetailsChart(data: data, colorMapping: ingestionData.colorMapping)
                    .frame(height: 300)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("Substances")
    }
}

@available(iOS 16, *)
struct IngestionDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IngestionDetails(ingestionData: .mock1)
        }
    }
}
