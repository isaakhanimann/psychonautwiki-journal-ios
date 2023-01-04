//
//  SuggestionBox.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 14.12.22.
//

import SwiftUI
import WrappingHStack

struct SuggestionBox: View {

    let suggestion: Suggestion
    let dismiss: () -> Void
    
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
                    }.buttonStyle(.bordered).padding(.trailing, 4).fixedSize()
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
                    }.buttonStyle(.bordered).padding(.trailing, 4).fixedSize()
                }
                if index == suggestion.dosesAndUnit.count-1 {
                    if let substance = suggestion.substance {
                        NavigationLink("Other") {
                            if substance.name == "Cannabis" && suggestion.route == .smoked {
                                ChooseCannabisSmokedDoseScreen(dismiss: dismiss)
                            } else {
                                ChooseDoseScreen(
                                    substance: substance,
                                    administrationRoute: suggestion.route,
                                    dismiss: dismiss
                                )
                            }
                        }.buttonStyle(.borderedProminent).padding(.trailing, 4).fixedSize()
                    } else {
                        NavigationLink("Other") {
                            CustomChooseDoseScreen(
                                substanceName: suggestion.substanceName,
                                units: suggestion.units,
                                administrationRoute: suggestion.route,
                                dismiss: dismiss)
                        }.buttonStyle(.borderedProminent).padding(.trailing, 4).fixedSize()
                    }
                }
            }
        } label: {
            Label(
                "\(suggestion.substanceName) \(suggestion.route.rawValue.localizedCapitalized)",
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
                    dismiss: {})
                SuggestionBox(
                    suggestion: Suggestion(
                        substanceName: "Cannabis",
                        substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                        units: "mg (THC)",
                        route: .smoked,
                        substanceColor: .green,
                        dosesAndUnit: [
                            DoseAndUnit(
                                dose: 3,
                                units: "mg  (THC)",
                                isEstimate: false
                            ),
                            DoseAndUnit(
                                dose: 6,
                                units: "mg (THC)",
                                isEstimate: true
                            ),
                            DoseAndUnit(
                                dose: nil,
                                units: "mg (THC)",
                                isEstimate: false
                            ),
                            DoseAndUnit(
                                dose: 2.5,
                                units: "mg (THC)",
                                isEstimate: false
                            )
                        ]
                    ),
                    dismiss: {})
            }.padding(.horizontal)
        }
    }
}
