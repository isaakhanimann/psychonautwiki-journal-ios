//
//  ChooseCaffeineDoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

import SwiftUI
import WrappingHStack

struct ChooseCaffeineDoseScreen: View {
    let dismiss: () -> Void
    let caffeine = SubstanceRepo.shared.getSubstance(name: "Caffeine")!
    var oralDose: RoaDose {
        caffeine.getDose(for: .oral)!
    }
    @State private var caffeineDoseInMg = 50.0
    @State private var isEstimate = true
    let units = "mg"

    private var doseRounded: Double {
        round(caffeineDoseInMg)
    }

    private var doseText: String {
        String(Int(doseRounded))
    }

    var body: some View {
        Form {
            Section("Ingested Caffeine Amount") {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: caffeineDoseInMg, with: units)
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: oralDose)
                    Slider(
                        value: $caffeineDoseInMg,
                        in: 10...900,
                        step: 10
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("900")
                    }
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
            }
            Section("Average Drinks") {
                Button("240 mL Coffee") {
                    caffeineDoseInMg = 90
                }
                Button("350 mL Caffeinated Soft Drink") {
                    caffeineDoseInMg = 35
                }
                Button("240 mL Black/Green Tea") {
                    caffeineDoseInMg = 40
                }
                Button("240 mL Energy Drink Light") {
                    caffeineDoseInMg = 40
                }
                Button("240 mL Energy Drink Strong") {
                    caffeineDoseInMg = 250
                }
            }
            if let remark = caffeine.dosageRemark {
                Text(remark)
            }
        }
        .navigationTitle("Caffeine Dosage")
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
                        substanceName: caffeine.name,
                        administrationRoute: .oral,
                        dose: nil,
                        units: units,
                        isEstimate: false,
                        dismiss: dismiss
                    )
                }
                NavigationLink {
                    FinishIngestionScreen(
                        substanceName: caffeine.name,
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

struct ChooseCaffeineDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseCaffeineDoseScreen(dismiss: {})
        }
    }
}
