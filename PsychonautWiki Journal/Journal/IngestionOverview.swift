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
        Chart(TopStyleData.last12Months, id: \.name) { element in
            BarMark(
                x: .value("Sales", element.sales),
                y: .value("Name", element.name)
            )
            .opacity(element.name == TopStyleData.last30Days.first!.name ? 1 : 0.5)
        }
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
            Text(TopStyleData.last30Days.first!.name)
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
