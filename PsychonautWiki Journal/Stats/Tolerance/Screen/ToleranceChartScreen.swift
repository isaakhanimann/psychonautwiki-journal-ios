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
struct ToleranceChartScreen: View {

    @State private var sinceDate = Date().addingTimeInterval(-3*30*24*60*60)
    @State private var toleranceWindows: [ToleranceWindow] = []
    @State private var substancesInIngestionsButNotChart: [String] = []
    @State private var numberOfSubstancesInChart = 0

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    @FetchRequest(
        sortDescriptors: []
    ) var substanceCompanions: FetchedResults<SubstanceCompanion>

    var body: some View {
        ToleranceChartScreenContent(toleranceWindows: toleranceWindows,
                                    sinceDate: $sinceDate,
                                    substancesInIngestionsButNotChart: substancesInIngestionsButNotChart,
                                    numberOfSubstancesInChart: numberOfSubstancesInChart)
        .onAppear(perform: calculateScreen)
        .onChange(of: ingestions.count) { _ in
            calculateScreen()
        }
        .onChange(of: sinceDate) { _ in
            calculateScreen()
        }
        .dismissWhenTabTapped()
    }

    func calculateScreen() {
        let relevantIngestions = ingestions.prefix { ing in
            ing.timeUnwrapped > sinceDate
        }
        toleranceWindows = ToleranceChartCalculator.getToleranceWindows(from: Array(relevantIngestions), substanceCompanions: Array(substanceCompanions))
        let substancesInIngestions = Set(relevantIngestions.map({$0.substanceNameUnwrapped}))
        let substancesInToleranceWindows = Set(toleranceWindows.map({$0.substanceName}))
        numberOfSubstancesInChart = substancesInToleranceWindows.count
        let substancesWithoutToleranceWindows = substancesInIngestions.subtracting(substancesInToleranceWindows)
        substancesInIngestionsButNotChart = Array(substancesWithoutToleranceWindows)
    }
}
