//
//  ChooseMDMADoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

import SwiftUI

struct ChooseMDMADoseScreen: View {
    let dismiss: () -> Void
    private let mdma = SubstanceRepo.shared.getSubstance(name: "MDMA")!
    private var oralDose: RoaDose {
        mdma.getDose(for: .oral)!
    }
    @State private var mdmaDoseInMg = 100.0
    @State private var isEstimate = false
    private let units = "mg"
    private var doseRounded: Double {
        round(mdmaDoseInMg)
    }
    private var doseText: String {
        String(Int(doseRounded))
    }

    var body: some View {
        Form {
            Section("Max Dose Calculator") {
                MDMAMaxDoseCalculator()
            }
            Section("Choose Dose") {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: mdmaDoseInMg, with: units)
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: oralDose)
                    Slider(
                        value: $mdmaDoseInMg,
                        in: 10...400,
                        step: 10
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("400")
                    }
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
            }
            if #available(iOS 16, *) {
                MDMAOptimalDoseSection()
            }
            MDMAPillsSection()
        }
        .navigationTitle("MDMA Dosage")
        .headerProminence(.increased)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                NavigationLink("Unknown Dose") {
                    FinishIngestionScreen(
                        substanceName: mdma.name,
                        administrationRoute: .oral,
                        dose: nil,
                        units: units,
                        isEstimate: false,
                        dismiss: dismiss
                    )
                }
                NavigationLink {
                    FinishIngestionScreen(
                        substanceName: mdma.name,
                        administrationRoute: .oral,
                        dose: doseRounded,
                        units: units,
                        isEstimate: isEstimate,
                        dismiss: dismiss
                    )
                } label: {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }
            }
        }
    }
}

struct ChooseMDMADoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseMDMADoseScreen(dismiss: {})
        }
    }
}
