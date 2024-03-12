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

struct ToleranceTextsScreen: View {
    let substances: [SubstanceWithToleranceAndColor]

    var body: some View {
        List {
            ForEach(substances) { substance in
                Section {
                    if let full = substance.full {
                        RowLabelView(label: "full", value: full)
                    }
                    if let half = substance.half {
                        RowLabelView(label: "half", value: half)
                    }
                    if let zero = substance.zero {
                        RowLabelView(label: "zero", value: zero)
                    }
                    let crossTolerances = substance.crossTolerances.joined(separator: ", ")
                    if !crossTolerances.isEmpty {
                        Text("Cross tolerance with \(crossTolerances)")
                    }
                } header: {
                    HStack {
                        Image(systemName: "circle.fill").foregroundColor(substance.color.swiftUIColor)
                        Text(substance.substanceName)
                    }
                }
            }
        }
        .navigationTitle("Tolerances")
        .toolbar {
            NavigationLink(value: GlobalNavigationDestination.toleranceChartExplanation) {
                Label("Chart Limitations", systemImage: "info.circle")
                    .labelStyle(.titleOnly)
            }
        }
    }
}

#Preview {
    NavigationStack {
        let substances = Array(SubstanceRepo.shared.substances.filter { sub in
            guard let tolerance = sub.tolerance else { return false }
            return tolerance.halfToleranceInHours != nil && tolerance.zeroToleranceInHours != nil
        }.shuffled().prefix(5))
        let substancsWith = substances.map { sub in
            sub.toSubstanceWithToleranceAndColor(substanceColor: SubstanceColor.allCases.randomElement() ?? .red)
        }
        ToleranceTextsScreen(substances: substancsWith)
    }
}
