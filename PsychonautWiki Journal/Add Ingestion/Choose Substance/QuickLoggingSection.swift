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
    let dismiss: () -> Void

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
                    ForEach(suggestion.routesAndDoses) { routeAndDoses in
                        Spacer().frame(height: 5)
                        GroupBox(routeAndDoses.route.rawValue.localizedCapitalized) {
                            WrappingHStack(
                                routeAndDoses.doses,
                                alignment: .leading,
                                spacing: .constant(3),
                                lineSpacing: 3
                            ) { dose in
                                if let doseUnwrap = dose.dose {
                                    NavigationLink("\(doseUnwrap.formatted()) \(dose.units ?? "")") {
                                        ChooseTimeAndColor(
                                            substanceName: suggestion.substanceName,
                                            administrationRoute: routeAndDoses.route,
                                            dose: doseUnwrap,
                                            units: dose.units,
                                            dismiss: dismiss
                                        )
                                    }.buttonStyle(.bordered).fixedSize()
                                } else {
                                    NavigationLink("Unknown") {
                                        ChooseTimeAndColor(
                                            substanceName: suggestion.substanceName,
                                            administrationRoute: routeAndDoses.route,
                                            dose: dose.dose,
                                            units: dose.units,
                                            dismiss: dismiss
                                        )
                                    }.buttonStyle(.bordered).fixedSize()
                                }
                                if let lastDose = routeAndDoses.doses.last, dose.id == lastDose.id {
                                    if let substance = suggestion.substance {
                                        NavigationLink("Other") {
                                            ChooseDoseScreen(
                                                substance: substance,
                                                administrationRoute: routeAndDoses.route,
                                                dismiss: dismiss
                                            )
                                        }.buttonStyle(.bordered).fixedSize()
                                    } else {
//                                        NavigationLink("Other") {
//                                            CustomChooseDoseScreen(
//                                                substanceName: suggestion.substanceName,
//                                                units: routeAndDoses.units,
//                                                administrationRoute: routeAndDoses.route,
//                                                dismiss: dismiss)
//                                        }.buttonStyle(.borderedProminent).fixedSize()
                                    }

                                }
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
                        substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                        substanceColor: .blue,
                        routesAndDoses: [
                            RouteAndDoses(
                                route: .oral,
                                units: "mg",
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
                                units: "mg",
                                doses: [
                                    DoseAndUnit(dose: 40, units: "mg"),
                                    DoseAndUnit(dose: 30, units: "mg"),

                                ]
                            )
                        ]
                    ),
                    Suggestion(
                        substanceName: "Cocaine",
                        substance: SubstanceRepo.shared.getSubstance(name: "Cocaine"),
                        substanceColor: .yellow,
                        routesAndDoses: [
                            RouteAndDoses(
                                route: .insufflated,
                                units: "mg",
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
                        substanceName: "Coffee",
                        substance: nil,
                        substanceColor: .brown,
                        routesAndDoses: [
                            RouteAndDoses(
                                route: .oral,
                                units: "cups",
                                doses: [
                                    DoseAndUnit(dose: 2, units: "cups"),
                                    DoseAndUnit(dose: 5, units: "cups"),

                                ]
                            )
                        ]
                    )
                ],
                dismiss: {}
                )
            }
        }
    }
}
