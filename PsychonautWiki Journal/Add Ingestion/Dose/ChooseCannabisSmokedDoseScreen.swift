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
        cannabisAmountInMg * Double(pickerOption.percentTransfer) / 100 * thcContent / 100
    }

    private var doseRounded: Double {
        Double(round(10 * ingestedTHCDoseInMg) / 10)
    }

    private var doseText: String {
        String(format: "%.1f", ingestedTHCDoseInMg)
    }

    private var suggestedNote: String {
        "\(Int(cannabisAmountInMg)) mg Cannabis (\(Int(thcContent))% THC) smoked in a \(pickerOption.rawValue)"
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
        screen.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                nextLink
            }
        }
    }

    private var nextLink: some View {
        NavigationLink(value: FinishIngestionScreenArguments(
            substanceName: cannabis.name,
            administrationRoute: .smoked,
            dose: doseRounded,
            units: "mg",
            isEstimate: isEstimate,
            suggestedNote: suggestedNote
        )) {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Unknown Dose", value: FinishIngestionScreenArguments(
            substanceName: cannabis.name,
            administrationRoute: .smoked,
            dose: nil,
            units: "mg",
            isEstimate: false))
    }

    private var screen: some View {
        Form {
            Section("Ingested THC Amount") {
                VStack(spacing: 5) {
                    let doseType = smokedDose.getRangeType(for: ingestedTHCDoseInMg, with: "mg")
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: smokedDose)
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
                unknownDoseLink
            }
            Section {
                Picker("Form", selection: $pickerOption) {
                    ForEach(PickerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                Text("THC Transfer: ~\(pickerOption.percentTransfer)%").font(.headline.bold())
            }
            Section("Cannabis Amount") {
                VStack {
                    Text("\(Int(cannabisAmountInMg)) mg").font(.title2.bold())
                    Slider(
                        value: $cannabisAmountInMg,
                        in: 10 ... 1000,
                        step: 10
                    ) {
                        Text("Cannabis Amount")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("1'000")
                    }
                }
            }.listRowSeparator(.hidden)
            Section("THC Content") {
                VStack {
                    Text("\(Int(thcContent))%").font(.title2.bold())
                    Slider(
                        value: $thcContent,
                        in: 1 ... 30,
                        step: 1
                    ) {
                        Text("THC Content")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("30")
                    }
                }
            }
            if let remark = cannabis.dosageRemark {
                Text(remark)
            }
        }
        .navigationTitle("Cannabis Smoked")
    }
}

struct ChooseJointDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChooseCannabisSmokedDoseScreen(dismiss: {})
        }
    }
}
