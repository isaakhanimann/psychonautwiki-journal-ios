//
//  IngestionDetails.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

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
                Text(data.first?.substanceName ?? "Unknown")
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
