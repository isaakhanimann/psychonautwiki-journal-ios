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

struct ChooseCaffeineDoseScreen: View {
    let dismiss: () -> Void
    let caffeine = SubstanceRepo.shared.getSubstance(name: "Caffeine")!
    var oralDose: RoaDose {
        caffeine.getDose(for: .oral)!
    }

    @State private var caffeineDoseInMg = 50.0
    @State private var isEstimate = true
    @State private var doseDeviationInMg: Double?
    let units = "mg"

    private var doseRounded: Double {
        round(caffeineDoseInMg)
    }

    private var doseText: String {
        String(Int(doseRounded))
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
            substanceName: caffeine.name,
            administrationRoute: .oral,
            dose: doseRounded,
            units: units,
            isEstimate: isEstimate,
            estimatedDoseStandardDeviation: doseDeviationInMg
        )) {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Unknown Dose", value: FinishIngestionScreenArguments(
            substanceName: caffeine.name,
            administrationRoute: .oral,
            dose: nil,
            units: units,
            isEstimate: false,
            estimatedDoseStandardDeviation: nil))
    }

    @FocusState private var isEstimatedDeviationFocused: Bool

    var screen: some View {
        Form {
            Section {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: caffeineDoseInMg, with: units)
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    RoaDoseRow(roaDose: oralDose)
                    Slider(
                        value: $caffeineDoseInMg,
                        in: 10 ... 900,
                        step: 10
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("900")
                    }
                }
                Toggle("Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                    .onChange(of: isEstimate, perform: { newIsEstimate in
                        if newIsEstimate {
                            isEstimatedDeviationFocused = true
                        }
                    })
                if isEstimate {
                    HStack {
                        Image(systemName: "plusminus")
                        TextField(
                            "Pure dose standard deviation",
                            value: $doseDeviationInMg,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($isEstimatedDeviationFocused)
                        Spacer()
                        Text(units)
                    }
                }
                unknownDoseLink
            }.listRowSeparator(.hidden)
            Section("Average Drinks") {
                Group {
                    Button("Caffe Nero Espresso (45 mg)") {
                        caffeineDoseInMg = 45
                    }
                    Button("Costa Espresso (100 mg)") {
                        caffeineDoseInMg = 100
                    }
                    Button("Gregs Espresso (75 mg)") {
                        caffeineDoseInMg = 75
                    }
                    Button("Pret Espresso (180 mg)") {
                        caffeineDoseInMg = 180
                    }
                    Button("Starbucks Espresso (33 mg)") {
                        caffeineDoseInMg = 33
                    }
                }
                Group {
                    Button("Caffe Nero Cappuccino (115 mg)") {
                        caffeineDoseInMg = 115
                    }
                    Button("Costa Cappuccino (325 mg)") {
                        caffeineDoseInMg = 325
                    }
                    Button("Gregs Cappuccino (197 mg)") {
                        caffeineDoseInMg = 197
                    }
                    Button("Pret Cappuccino (180 mg)") {
                        caffeineDoseInMg = 180
                    }
                    Button("Starbucks Cappuccino (66 mg)") {
                        caffeineDoseInMg = 66
                    }
                }
                Group {
                    Button("Greggs Filter/Brewed Coffee (225 mg)") {
                        caffeineDoseInMg = 225
                    }
                    Button("Pret Filter/Brewed Coffee (271 mg)") {
                        caffeineDoseInMg = 271
                    }
                    Button("Starbucks Filter/Brewed Coffee (102 mg)") {
                        caffeineDoseInMg = 102
                    }
                }
                Button("Tea (75 mg)") {
                    caffeineDoseInMg = 75
                }
                Button("Caffeinated Soft Drink (35 mg)") {
                    caffeineDoseInMg = 35
                }
                Button("Typical Energy Drink (80 mg)") {
                    caffeineDoseInMg = 80
                }
                Button("Energy Drink Light (40 mg)") {
                    caffeineDoseInMg = 40
                }
                Button("Energy Drink Strong (250 mg)") {
                    caffeineDoseInMg = 250
                }
                Button("45g Dark Chocolate bar (18 mg)") {
                    caffeineDoseInMg = 18
                }
            }
            if let remark = caffeine.dosageRemark {
                Text(remark)
            }
        }
        .navigationTitle("Caffeine Dose")
    }
}

#Preview {
    NavigationStack {
        ChooseCaffeineDoseScreen(dismiss: {})
    }
}
