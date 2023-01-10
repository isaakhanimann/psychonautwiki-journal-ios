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
