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
    @StateObject private var viewModel = ViewModel()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    @FetchRequest(
        sortDescriptors: []
    ) var substanceCompanions: FetchedResults<SubstanceCompanion>

    @State private var experienceData: ExperienceData? = nil
    @State private var ingestionData: IngestionData? = nil

    var body: some View {
        VStack {
            DatePicker(
                    "Start Date",
                    selection: $sinceDate,
                    displayedComponents: [.date]
            )
            ToleranceChart(toleranceWindows: viewModel.toleranceWindows)
                .frame(minHeight: 500)
        }
        .padding(.all)
        .navigationTitle("Tolerance")
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
        viewModel.setToleranceWindows(from: Array(relevantIngestions), substanceCompanions: Array(substanceCompanions))
    }
}

