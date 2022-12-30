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

    let ingestionData: IngestionData

    var body: some View {
        Chart(ingestionData.last12Months) { element in
            BarMark(
                x: .value("Ingestions", element.ingestionCount),
                y: .value("Substance", element.substanceName)
            )
            .foregroundStyle(by: .value("Substance", element.substanceName))
            .opacity(element.substanceName == ingestionData.last30Days.first!.substanceName ? 1 : 0.5)
        }
        .chartForegroundStyleScale(mapping: ingestionData.last12MonthsColorMapping)
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
            Text("Most Used Substance")
                .foregroundStyle(.secondary)
            Text(ingestionData.last30Days.first!.substanceName)
                .font(.title2.bold())
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
