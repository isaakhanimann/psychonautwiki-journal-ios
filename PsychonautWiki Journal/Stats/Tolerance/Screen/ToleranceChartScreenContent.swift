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
    let onAddTap: () -> Void
    let substances: [SubstanceWithToleranceAndColor]

    var body: some View {
        List {
            Section {
                DatePicker(
                    "Start Date",
                    selection: $sinceDate,
                    displayedComponents: [.date]
                )
            }
            Section {
                ToleranceChart(
                    toleranceWindows: toleranceWindows,
                    numberOfRows: numberOfSubstancesInChart,
                    timeOption: .alwaysShow,
                    experienceStartDate: nil
                )
            } footer: {
                if !substancesInIngestionsButNotChart.isEmpty {
                    MissingToleranceText(substanceNames: substancesInIngestionsButNotChart)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Section {
                NavigationLink {
                    ToleranceChartExplanationScreen()
                } label: {
                    Label("Chart Limitations", systemImage: "info.circle")
                }
                if !substances.isEmpty {
                    NavigationLink {
                        ToleranceTextsScreen(substances: substances)
                    } label: {
                        Label("Tolerance Info", systemImage: "doc.plaintext")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAddTap) {
                    Label("Add Temporary Ingestion", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Tolerance")
    }
}

@available(iOS 16.0, *)
struct ToleranceChartScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ToleranceChartScreenContent(
                    toleranceWindows: ToleranceChartPreviewDataProvider.mock1,
                    sinceDate: .constant(Date()),
                    substancesInIngestionsButNotChart: ["2C-B", "DMT"],
                    numberOfSubstancesInChart: 2,
                    onAddTap: {},
                    substances: []
                )
            }
            NavigationView {
                ToleranceChartScreenContent(
                    toleranceWindows: [],
                    sinceDate: .constant(Date()),
                    substancesInIngestionsButNotChart: [],
                    numberOfSubstancesInChart: 0,
                    onAddTap: {},
                    substances: []
                )
            }
        }
    }
}
