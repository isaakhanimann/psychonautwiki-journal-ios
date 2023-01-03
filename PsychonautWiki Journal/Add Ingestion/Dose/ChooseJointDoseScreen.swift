//
//  ChooseJointDoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 03.01.23.
//

import SwiftUI

struct ChooseJointDoseScreen: View {

    @State private var cannabisAmountInMg = 300.0
    @State private var thcContent = 14.0
    let bioavailibility = 30.0

    var pureTHCDoseInMgRounded: Double {
        round(cannabisAmountInMg * pickerOption.value * thcContent / 100)
    }

    let smokedDose = SubstanceRepo.shared.getSubstance(name: "Cannabis")?.getDose(for: .smoked)

    enum PickerOption: String, CaseIterable {
        case quarter = "1/4"
        case third = "1/3"
        case half = "1/2"
        case threequarters = "3/4"
        case full = "1"

        var value: Double {
            switch self {
            case .quarter:
                return 0.25
            case .third:
                return 1/3.0
            case .half:
                return 0.5
            case .threequarters:
                return 0.75
            case .full:
                return 1
            }
        }
    }

    @State private var pickerOption = PickerOption.full

    var body: some View {
        Form {
            Section("Cannabis Amount") {
                Text("Joint Size").font(.headline)
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
                Text("Amount Smoked").font(.headline)
                Picker("Amount Smoked", selection: $pickerOption) {
                    ForEach(PickerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
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
            Section("Smoked THC") {
                VStack(spacing: 5) {
                    let doseType = smokedDose?.getRangeType(for: pureTHCDoseInMgRounded, with: "mg (THC)")
                    Text("\(Int(pureTHCDoseInMgRounded)) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType?.color ?? .primary)
                    DoseRow(roaDose: smokedDose)
                }
            }
        }.navigationTitle("Joint")
            .headerProminence(.increased)
    }
}

struct ChooseJointDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseJointDoseScreen()
        }
    }
}
