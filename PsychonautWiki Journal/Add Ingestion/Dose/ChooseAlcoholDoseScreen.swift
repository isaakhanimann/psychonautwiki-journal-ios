//
//  ChooseAlcoholDoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 04.01.23.
//

import SwiftUI

struct ChooseAlcoholDoseScreen: View {
    let dismiss: () -> Void
    let alcohol = SubstanceRepo.shared.getSubstance(name: "Alcohol")!
    var oralDose: RoaDose {
        alcohol.getDose(for: .oral)!
    }
    @State private var drinkAmountInCl = 5.0
    @State private var alcoholContentInPercent = 5.0
    @State private var isEstimate = true
    let units = "mL EtOH"

    private var ingestedAlcoholDoseInMl: Double {
        drinkAmountInCl * 100 * alcoholContentInPercent / 100
    }

    private var doseRounded: Double {
        round(ingestedAlcoholDoseInMl)
    }

    private var doseText: String {
        String(Int(doseRounded))
    }

    private var suggestedNote: String {
        "\(Int(drinkAmountInCl)) cL with \(Int(alcoholContentInPercent))% Alcohol"
    }

    var body: some View {
        Form {
            Section("Ingested Alcohol Amount") {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: ingestedAlcoholDoseInMl, with: units)
                    Text("\(doseText) mL")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: oralDose)
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
            }
            Section {
                VStack {
                    Text("\(Int(drinkAmountInCl)) cL").font(.title2.bold())
                    Slider(
                        value: $drinkAmountInCl,
                        in: 1...20,
                        step: 1
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("20")
                    }
                }
            } header: {
                Text("Drink Size")
            } footer: {
                Text("1 cL = 1/10 L")
            }
            Section("Alcohol Content") {
                VStack {
                    Text("\(Int(alcoholContentInPercent))%").font(.title2.bold())
                    Slider(
                        value: $alcoholContentInPercent,
                        in: 1...80,
                        step: 1
                    ) {
                        Text("Alcohol Content")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("80")
                    }
                }
                Button("Average Beer") {
                    alcoholContentInPercent = 5                }
                Button("Average Wine") {
                    alcoholContentInPercent = 12
                }
                Button("Average Spirit") {
                    alcoholContentInPercent = 40
                }
            }
            if let remark = alcohol.dosageRemark {
                Text(remark)
            }
        }
        .navigationTitle("Alcohol Dosage")
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
                        substanceName: alcohol.name,
                        administrationRoute: .oral,
                        dose: nil,
                        units: units,
                        isEstimate: false,
                        dismiss: dismiss
                    )
                }
                NavigationLink {
                    FinishIngestionScreen(
                        substanceName: alcohol.name,
                        administrationRoute: .oral,
                        dose: doseRounded,
                        units: units,
                        isEstimate: isEstimate,
                        dismiss: dismiss,
                        suggestedNote: suggestedNote
                    )
                } label: {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }
            }
        }
    }
}

struct ChooseAlcoholDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseAlcoholDoseScreen(dismiss: {})
        }
    }
}
