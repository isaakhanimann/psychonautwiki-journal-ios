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
    let data: [(name: String, sales: Int)]

    var body: some View {
        Chart(data, id: \.name) { element in
            BarMark(
                x: .value("Sales", element.sales),
                y: .value("Name", element.name)
            )
        }
    }
}

@available(iOS 16, *)
struct IngestionDetails: View {
    @State private var timeRange: TimeRange = .last30Days

    var data: [(name: String, sales: Int)] {
        switch timeRange {
        case .last30Days:
            return IngestionData.last30Days
        case .last12Months:
            return IngestionData.last12Months
        }
    }

    var body: some View {
        List {
            VStack(alignment: .leading) {
                TimeRangePicker(value: $timeRange)
                    .padding(.bottom)

                Text("Most Sold Style")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text(data.first?.name ?? "Unknown")
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                IngestionDetailsChart(data: data)
                    .frame(height: 300)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationBarTitle("Style", displayMode: .inline)
    }
}

@available(iOS 16, *)
struct IngestionDetails_Previews: PreviewProvider {
    static var previews: some View {
        IngestionDetails()
    }
}
