//
//  MDMADesirableVsAdverseChart.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct MDMADesirableVsAdverseChart: View {

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
            (dose: 180, effect: 1)
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
            (dose: 180, effect: 86)
        ])
    ]

    struct Series: Identifiable {
        let effectType: String
        let doseEffect: [(dose: Int, effect: Int)]
        var id: String { effectType }
    }

    var body: some View {
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
            MDMADesirableVsAdverseChart.desirable: .green,
            MDMADesirableVsAdverseChart.adverse: .red
        ])
        .chartSymbolScale([
            MDMADesirableVsAdverseChart.desirable: .circle,
            MDMADesirableVsAdverseChart.adverse: .cross
        ])
    }
}

@available(iOS 16.0, *)
struct MDMADesirableVsAdverseChart_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MDMADesirableVsAdverseChart().frame(height: 200)
        }
    }
}
