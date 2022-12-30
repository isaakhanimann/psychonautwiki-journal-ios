//
//  IngestionOverviewChart.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import Charts
import SwiftUI

@available(iOS 16, *)
struct IngestionOverviewChart: View {
    var body: some View {
        Chart(IngestionData.last12Months) { element in
            BarMark(
                x: .value("Ingestions", element.ingestionCount),
                y: .value("Substance", element.substanceName)
            )
            .foregroundStyle(by: .value("Substance", element.substanceName))
            .opacity(element.substanceName == IngestionData.last30Days.first!.substanceName ? 1 : 0.5)
        }
        .chartForegroundStyleScale(IngestionData.last12MonthsColors)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

@available(iOS 16, *)
struct IngestionOverview: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Sold Style")
                .foregroundStyle(.secondary)
            Text(IngestionData.last30Days.first!.substanceName)
                .font(.title2.bold())
            IngestionOverviewChart()
                .frame(height: 100)
        }
    }
}

@available(iOS 16, *)
struct IngestionOverview_Previews: PreviewProvider {
    static var previews: some View {
        IngestionOverview()
            .padding()
    }
}
