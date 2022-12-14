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
            WrappingHStack(spacing: .constant(0), lineSpacing: 5) {
                ForEach(suggestion.dosesAndUnit) { dose in
                    if let doseUnwrap = dose.dose {
                        NavigationLink("\(doseUnwrap.formatted()) \(dose.units ?? "")") {
                            ChooseTimeAndColor(
                                substanceName: suggestion.substanceName,
                                administrationRoute: suggestion.route,
                                dose: doseUnwrap,
                                units: dose.units,
                                dismiss: dismiss
                            )
                        }.buttonStyle(.bordered).padding(.trailing, 4).fixedSize()
                    } else {
                        NavigationLink("Unknown") {
                            ChooseTimeAndColor(
                                substanceName: suggestion.substanceName,
                                administrationRoute: suggestion.route,
                                dose: dose.dose,
                                units: dose.units,
                                dismiss: dismiss
                            )
                        }.buttonStyle(.bordered).padding(.trailing, 4).fixedSize()
                    }
                }
                if let substance = suggestion.substance {
                    NavigationLink("Other") {
                        ChooseDoseScreen(
                            substance: substance,
                            administrationRoute: suggestion.route,
                            dismiss: dismiss
                        )
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
                SuggestionBox(suggestion: Suggestion(
                    substanceName: "MDMA",
                    substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                    units: "mg",
                    route: .insufflated,
                    substanceColor: .pink,
                    dosesAndUnit: [
                        DoseAndUnit(
                            dose: 20,
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: nil,
                            units: "mg"
                        ),
                        DoseAndUnit(
                            dose: 30,
                            units: "mg"
                        )
                    ]
                ), dismiss: {}).padding(.horizontal)
            }
        }
    }
}
