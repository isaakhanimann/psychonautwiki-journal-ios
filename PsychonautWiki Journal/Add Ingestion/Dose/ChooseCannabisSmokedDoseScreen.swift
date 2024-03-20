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

    @State private var cannabisAmountInMg: Double?
    @State private var thcContent: Double?
    @State private var isEstimate = false
    @State private var doseDeviationInMg: Double?
    @State private var pickerOption = PickerOption.joint

    private var ingestedTHCDoseInMg: Double? {
        guard let cannabisAmountInMg, let thcContent else {return nil}
        return cannabisAmountInMg * Double(pickerOption.percentTransfer) / 100 * thcContent / 100
    }

    private var doseRounded: Double? {
        guard let ingestedTHCDoseInMg else {return nil}
        return Double(round(10 * ingestedTHCDoseInMg) / 10)
    }

    private var suggestedNote: String? {
        if let cannabisAmountInMg, let thcContent {
            return "\(Int(cannabisAmountInMg)) mg Cannabis (\(Int(thcContent))% THC) smoked in a \(pickerOption.rawValue.lowercased())"
        } else {
            return nil
        }
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
            estimatedDoseStandardDeviation: doseDeviationInMg,
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
            isEstimate: false,
            estimatedDoseStandardDeviation: doseDeviationInMg))
    }

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case cannabisAmount
        case thcContent
        case estimatedDeviation
    }


    private var screen: some View {
        Form {
            Section("Ingested THC Amount") {
                VStack(spacing: 5) {
                    if let ingestedTHCDoseInMg {
                        let doseType = smokedDose.getRangeType(for: ingestedTHCDoseInMg, with: "mg")
                        Text("\(ingestedTHCDoseInMg.asRoundedReadableString) mg")
                            .font(.title.bold())
                            .foregroundColor(doseType.color)
                    } else {
                        Text(" ")
                            .font(.title.bold())
                    }
                    RoaDoseRow(roaDose: smokedDose)
                }
                Toggle("Estimate", isOn: $isEstimate)
                    .tint(.accentColor)
                    .onChange(of: isEstimate, perform: { newIsEstimate in
                        if newIsEstimate {
                            focusedField = .estimatedDeviation
                        }
                    })
                if isEstimate {
                    HStack {
                        Image(systemName: "plusminus")
                        TextField(
                            "Estimated standard deviation",
                            value: $doseDeviationInMg,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .estimatedDeviation)
                        Spacer()
                        Text("mg")
                    }
                }
                unknownDoseLink
            }.listRowSeparator(.hidden)
            Section {
                Picker("Form", selection: $pickerOption) {
                    ForEach(PickerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                Text("THC Transfer: ~\(pickerOption.percentTransfer)%").font(.headline.bold())
            }
            Section("Amount and THC Content") {
                HStack {
                    TextField(
                        "Cannabis Amount",
                        value: $cannabisAmountInMg,
                        format: .number
                    )
                    .focused($focusedField, equals: .cannabisAmount)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                        focusedField = .thcContent
                    }
                    Spacer()
                    Text("mg")
                }.font(.headline)
                HStack {
                    TextField(
                        "THC Content",
                        value: $thcContent,
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .thcContent)
                    Spacer()
                    Text("%")
                }.font(.headline)
            }
            if let remark = cannabis.dosageRemark {
                Text(remark)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            focusedField = .cannabisAmount
        }
        .navigationTitle("Cannabis Smoked")
    }
}

#Preview {
    NavigationStack {
        ChooseCannabisSmokedDoseScreen(dismiss: {})
    }
}
