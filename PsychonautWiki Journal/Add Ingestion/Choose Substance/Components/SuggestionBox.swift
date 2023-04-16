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

import SwiftUI
import WrappingHStack

struct SuggestionBox: View {

    let suggestion: Suggestion
    let dismiss: () -> Void
    let isEyeOpen: Bool

    var body: some View {
        GroupBox {
            WrappingHStack(
                0..<suggestion.dosesAndUnit.count,
                id:\.self,
                spacing: .constant(0),
                lineSpacing: 5
            ) { index in
                let dose = suggestion.dosesAndUnit[index]
                if let doseUnwrap = dose.dose {
                    NavigationLink("\(dose.isEstimate ? "~" : "")\(doseUnwrap.formatted()) \(dose.units ?? "")") {
                        FinishIngestionScreen(
                            substanceName: suggestion.substanceName,
                            administrationRoute: suggestion.route,
                            dose: doseUnwrap,
                            units: dose.units,
                            isEstimate: dose.isEstimate,
                            dismiss: dismiss
                        )
                    }
                    .buttonStyle(.bordered).padding(.trailing, 4).fixedSize()
                } else {
                    NavigationLink("Unknown") {
                        FinishIngestionScreen(
                            substanceName: suggestion.substanceName,
                            administrationRoute: suggestion.route,
                            dose: dose.dose,
                            units: dose.units,
                            isEstimate: dose.isEstimate,
                            dismiss: dismiss
                        )
                    }
                    .buttonStyle(.bordered).padding(.trailing, 4).fixedSize()
                }
                if index == suggestion.dosesAndUnit.count-1 {
                    if let substance = suggestion.substance {
                        NavigationLink("Other") {
                            if substance.name == "Cannabis" && suggestion.route == .smoked {
                                ChooseCannabisSmokedDoseScreen(dismiss: dismiss)
                            } else if substance.name == "Alcohol" && suggestion.route == .oral {
                                ChooseAlcoholDoseScreen(dismiss: dismiss)
                            } else if substance.name == "Caffeine" && suggestion.route == .oral {
                                ChooseCaffeineDoseScreen(dismiss: dismiss)
                            } else if substance.name == "MDMA" && suggestion.route == .oral {
                                ChooseMDMADoseScreen(dismiss: dismiss)
                            } else if substance.name == "Psilocybin mushrooms" && suggestion.route == .oral {
                                ChooseShroomsDoseScreen(dismiss: dismiss)
                            } else {
                                ChooseDoseScreen(
                                    substance: substance,
                                    administrationRoute: suggestion.route,
                                    dismiss: dismiss
                                )
                            }
                        }
                        .buttonStyle(.borderedProminent).padding(.trailing, 4).fixedSize()
                    } else {
                        NavigationLink("Other") {
                            CustomChooseDoseScreen(
                                substanceName: suggestion.substanceName,
                                units: suggestion.units,
                                administrationRoute: suggestion.route,
                                dismiss: dismiss)
                        }
                        .buttonStyle(.borderedProminent).padding(.trailing, 4).fixedSize()
                    }
                }
            }
        } label: {
            let route = isEyeOpen ? suggestion.route.rawValue.localizedCapitalized : ""
            Label(
                "\(suggestion.substanceName) \(route)",
                systemImage: "circle.fill"
            )
            .foregroundColor(suggestion.substanceColor.swiftUIColor)
        }
    }
}

struct SuggestionBox_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LazyVStack {
                SuggestionBox(
                    suggestion: Suggestion(
                        substanceName: "MDMA",
                        substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                        units: "mg",
                        route: .insufflated,
                        substanceColor: .pink,
                        dosesAndUnit: [
                            DoseAndUnit(
                                dose: 20,
                                units: "mg",
                                isEstimate: true
                            ),
                            DoseAndUnit(
                                dose: nil,
                                units: "mg",
                                isEstimate: false
                            ),
                            DoseAndUnit(
                                dose: 30,
                                units: "mg",
                                isEstimate: false
                            )
                        ]
                    ),
                    dismiss: {},
                    isEyeOpen: true
                )
                SuggestionBox(
                    suggestion: Suggestion(
                        substanceName: "Cannabis",
                        substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                        units: "mg",
                        route: .smoked,
                        substanceColor: .green,
                        dosesAndUnit: [
                            DoseAndUnit(
                                dose: 3,
                                units: "mg",
                                isEstimate: false
                            ),
                            DoseAndUnit(
                                dose: 6,
                                units: "mg",
                                isEstimate: true
                            ),
                            DoseAndUnit(
                                dose: nil,
                                units: "mg",
                                isEstimate: false
                            ),
                            DoseAndUnit(
                                dose: 2.5,
                                units: "mg",
                                isEstimate: false
                            )
                        ]
                    ),
                    dismiss: {},
                    isEyeOpen: true
                )
            }.padding(.horizontal)
        }
    }
}
