// Copyright (c) 2023. Isaak Hanimann.
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

import SwiftUI

@available(iOS 16.0, *)
struct ToleranceChartScreenContent: View {

    let toleranceWindows: [ToleranceWindow]
    @Binding var sinceDate: Date
    let substancesInIngestionsButNotChart: [String]
    let numberOfSubstancesInChart: Int

    private let chartExplanation = "Opaque color marks the period right after an ingestion where your tolerance to that particular substance might be high. More transparent color ranges afterwards indicate the period where there is still a light tolerance. After that you have zero tolerance again which means the dose needs to be adjusted like the first time you consumed it. Cross tolerances are not considered in this chart. The start date indicates the earliest date from which ingestions are considered. The vertical rule mark indicates the current time. This information is just a guideline. Tolerance decreases gradually. For many substances full tolerance develops after prolonged and repeated use and in case of repeated heavy doses it might take longer for the tolerance to reset. It is always safer, especially after a break to start using a low dose. Read the PsychonautWiki article on the specific substance for more info."

    var body: some View {
        List {
            Section {
                NavigationLink {
                    VStack {
                        Text(chartExplanation)
                        Spacer()
                    }
                    .padding(.all)
                    .navigationTitle("Chart Explanation")
                } label: {
                    Text(chartExplanation)
                        .lineLimit(2)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                DatePicker(
                        "Start Date",
                        selection: $sinceDate,
                        displayedComponents: [.date]
                )
                ToleranceChart(toleranceWindows: toleranceWindows, height: CGFloat(numberOfSubstancesInChart) * 80)
            } footer: {
                if !substancesInIngestionsButNotChart.isEmpty {
                    (Text("Excluding ") + Text(substancesInIngestionsButNotChart, format: .list(type: .and)) + Text(" because of missing tolerance info."))
                }
            }.listRowSeparator(.hidden)
        }
        .navigationTitle("Tolerance")
    }
}

@available(iOS 16.0, *)
struct ToleranceChartScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ToleranceChartScreenContent(
                toleranceWindows: ToleranceChartPreviewDataProvider.mock1,
                sinceDate: .constant(Date()),
                substancesInIngestionsButNotChart: ["2C-B", "DMT"],
                numberOfSubstancesInChart: 2
            )
        }
    }
}
