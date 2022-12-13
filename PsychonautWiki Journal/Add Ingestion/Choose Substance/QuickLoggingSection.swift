//
//  QuickLoggingSection.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 13.12.22.
//

import SwiftUI
import WrappingHStack

struct QuickLoggingSection: View {

    let suggestions: [Suggestion]

    let doseColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        Section("Quick Logging") {
            ForEach(suggestions) { suggestion in
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 5) {
                        Image(systemName: "circle.fill")
                            .font(.title2)
                            .foregroundColor(suggestion.substanceColor.swiftUIColor)
                        Text(suggestion.substanceName).font(.headline)
                    }
                    ForEach(suggestion.routesAndDoses) { route in
                        Spacer().frame(height: 5)
                        Text(route.route.rawValue.localizedCapitalized)
                        WrappingHStack(
                            route.doses,
                            alignment: .leading,
                            spacing: .constant(3),
                            lineSpacing: 3
                        ) { dose in
                            if let doseUnwrap = dose.dose {
                                Button("\(doseUnwrap.formatted()) \(dose.units ?? "")") {
                                    // TODO:
                                }.buttonStyle(.bordered).fixedSize().padding(2)
                            } else {
                                Button("Unknown") {
                                    // TODO:
                                }.buttonStyle(.bordered).fixedSize().padding(2)
                            }
                            if let lastDose = route.doses.last, dose.id == lastDose.id {
                                Button("Other") {
                                    // TODO:
                                }.buttonStyle(.bordered).padding(2)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct QuickLoggingSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                QuickLoggingSection(suggestions: [
                    Suggestion(
                        substanceName: "MDMA",
                        isCustom: false,
                        substanceColor: .blue,
                        routesAndDoses: [
                            RouteAndDoses(
                                route: .oral,
                                doses: [
                                    DoseAndUnit(dose: 50, units: "mg"),
                                    DoseAndUnit(dose: 100, units: "mg"),
                                    DoseAndUnit(dose: 30, units: "mg"),
                                    DoseAndUnit(dose: 80, units: "mg"),
                                    DoseAndUnit(dose: 70, units: "mg"),
                                    DoseAndUnit(dose: nil, units: "mg"),
                                ]
                            ),
                            RouteAndDoses(
                                route: .insufflated,
                                doses: [
                                    DoseAndUnit(dose: 40, units: "mg"),
                                    DoseAndUnit(dose: 30, units: "mg"),

                                ]
                            )
                        ]
                    ),
                    Suggestion(
                        substanceName: "Cocaine",
                        isCustom: false,
                        substanceColor: .yellow,
                        routesAndDoses: [
                            RouteAndDoses(
                                route: .insufflated,
                                doses: [
                                    DoseAndUnit(dose: 20, units: "mg"),
                                    DoseAndUnit(dose: 40, units: "mg"),
                                    DoseAndUnit(dose: 30, units: "mg"),
                                    DoseAndUnit(dose: 80, units: "mg"),
                                ]
                            )
                        ]
                    ),
                    Suggestion(
                        substanceName: "Cannabis",
                        isCustom: false,
                        substanceColor: .green,
                        routesAndDoses: [
                            RouteAndDoses(
                                route: .smoked,
                                doses: [
                                    DoseAndUnit(dose: 1.5, units: "mg"),
                                    DoseAndUnit(dose: 5, units: "mg"),
                                    DoseAndUnit(dose: 8, units: "mg"),
                                    DoseAndUnit(dose: 2, units: "mg"),
                                    DoseAndUnit(dose: nil, units: "mg"),
                                ]
                            ),
                            RouteAndDoses(
                                route: .oral,
                                doses: [
                                    DoseAndUnit(dose: 2, units: "mg"),
                                    DoseAndUnit(dose: 5, units: "mg"),

                                ]
                            )
                        ]
                    )
                ])
            }
        }
    }
}
