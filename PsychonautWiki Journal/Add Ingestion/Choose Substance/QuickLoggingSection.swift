//
//  QuickLoggingSection.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 13.12.22.
//

import SwiftUI

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
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Image(systemName: "circle.fill")
                            .font(.title2)
                            .foregroundColor(suggestion.substanceColor.swiftUIColor)
                        Text(suggestion.substanceName).font(.headline)
                    }
                    ForEach(suggestion.routesAndDoses) { route in
                        Text(route.route.rawValue)
                        LazyVGrid(columns: doseColumns) {
                            ForEach(route.doses) { dose in
                                if let doseUnwrap = dose.dose {
                                    Button("\(doseUnwrap.formatted()) \(dose.units ?? "")") {
                                        // TODO:
                                    }.buttonStyle(.bordered)
                                } else {
                                    Button("Unknown") {
                                        // TODO:
                                    }.buttonStyle(.bordered)
                                }
                            }
                            Button("Other") {
                                // TODO:
                            }.buttonStyle(.bordered)
                        }.background(Color.green).frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        ).background(Color.brown)
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
