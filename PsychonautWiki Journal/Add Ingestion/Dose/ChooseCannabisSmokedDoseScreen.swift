//
//  ChooseCannabisSmokedDoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 03.01.23.
//

import SwiftUI

struct ChooseCannabisSmokedDoseScreen: View {

    let dismiss: () -> Void
    let cannabis = SubstanceRepo.shared.getSubstance(name: "Cannabis")!
    var smokedDose: RoaDose {
        cannabis.getDose(for: .smoked)!
    }
    @State private var cannabisAmountInMg = 300.0
    @State private var thcContent = 14.0
    @State private var isEstimate = true
    @State private var pickerOption = PickerOption.joint

    private var ingestedTHCDoseInMg: Double {
        cannabisAmountInMg * Double(pickerOption.percentTransfer)/100 * thcContent / 100
    }

    private var doseText: String {
        String(format: "%.1f", ingestedTHCDoseInMg)
    }

    private var suggestedNote: String {
        "\(Int(cannabisAmountInMg)) mg Cannabis (\(Int(thcContent)) % THC) smoked in a \(pickerOption.rawValue)"
    }

    enum PickerOption: String, CaseIterable {
        case joint = "Joint"
        case bong = "Bong"
        case vaporizer = "Vaporizer"

        var percentTransfer: Int {
            switch self {
            case .joint:
                return 23
            case .bong:
                return 40
            case .vaporizer:
                return 70
            }
        }
    }

    var body: some View {
        Form {
            Section("Ingested THC Amount") {
                VStack(spacing: 5) {
                    let doseType = smokedDose.getRangeType(for: ingestedTHCDoseInMg, with: "mg (THC)")
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: smokedDose)
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
            }
            Section {
                Picker("Form", selection: $pickerOption) {
                    ForEach(PickerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                Text("THC Transfer: ~\(pickerOption.percentTransfer) %").font(.headline.bold())
            }
            Section("Cannabis Amount") {
                VStack {
                    Slider(
                        value: $cannabisAmountInMg,
                        in: 10...1000,
                        step: 10
                    ) {
                        Text("Cannabis Amount")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("1'000")
                    }
                    Text("\(Int(cannabisAmountInMg)) mg").font(.title2.bold())
                }
            }.listRowSeparator(.hidden)
            Section("THC Content") {
                VStack {
                    Slider(
                        value: $thcContent,
                        in: 1...30,
                        step: 1
                    ) {
                        Text("THC Content")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("30")
                    }
                    Text("\(Int(thcContent)) %").font(.title2.bold())
                }
            }
        }
        .navigationTitle("Cannabis Smoked")
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
                        substanceName: cannabis.name,
                        administrationRoute: .smoked,
                        dose: nil,
                        units: "mg (THC)",
                        isEstimate: false,
                        dismiss: dismiss
                    )
                }
                NavigationLink {
                    FinishIngestionScreen(
                        substanceName: cannabis.name,
                        administrationRoute: .smoked,
                        dose: ingestedTHCDoseInMg,
                        units: "mg (THC)",
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

struct ChooseJointDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseCannabisSmokedDoseScreen(dismiss: {})
        }
    }
}
