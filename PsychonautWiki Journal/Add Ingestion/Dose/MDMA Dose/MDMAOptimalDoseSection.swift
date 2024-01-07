// Copyright (c) 2022. Isaak Hanimann.
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

import Charts
import SwiftUI

struct MDMAOptimalDoseSection: View {
    private static let desirable = "Desirable"
    private static let adverse = "Adverse"

    private let data: [Series] = [
        .init(effectType: desirable, doseEffect: [
            (dose: 10, effect: 18),
            (dose: 30, effect: 29),
            (dose: 50, effect: 66),
            (dose: 70, effect: 83),
            (dose: 90, effect: 88),
            (dose: 110, effect: 81),
            (dose: 130, effect: 75),
            (dose: 150, effect: 62),
            (dose: 170, effect: 36),
            (dose: 180, effect: 1),
        ]),
        .init(effectType: adverse, doseEffect: [
            (dose: 10, effect: 5),
            (dose: 30, effect: 5),
            (dose: 50, effect: 4),
            (dose: 70, effect: 5),
            (dose: 90, effect: 6),
            (dose: 110, effect: 8),
            (dose: 130, effect: 15),
            (dose: 150, effect: 21),
            (dose: 170, effect: 55),
            (dose: 180, effect: 86),
        ]),
    ]

    struct Series: Identifiable {
        let effectType: String
        let doseEffect: [(dose: Int, effect: Int)]
        var id: String { effectType }
    }

    var body: some View {
        Section("Desirable vs Adverse Effects") {
            VStack {
                Text("The optimal single oral dose for an average user may be around 90 mg going by this diagram made by a Dutch street drug testing service.")
                Chart(data) { series in
                    ForEach(series.doseEffect, id: \.dose) { doseEffect in
                        LineMark(
                            x: .value("Dose in mg", doseEffect.dose),
                            y: .value("Effect in percent", doseEffect.effect)
                        )
                    }
                    .foregroundStyle(by: .value("Effect", series.effectType))
                    .symbol(by: .value("Effect", series.effectType))
                    .interpolationMethod(.catmullRom)
                }
                .chartForegroundStyleScale([
                    MDMAOptimalDoseSection.desirable: .green,
                    MDMAOptimalDoseSection.adverse: .red,
                ])
                .chartSymbolScale([
                    MDMAOptimalDoseSection.desirable: .circle,
                    MDMAOptimalDoseSection.adverse: .cross,
                ])
                .frame(height: 200)
            }
        }
    }
}

#Preview {
    List {
        MDMAOptimalDoseSection()
    }
}
