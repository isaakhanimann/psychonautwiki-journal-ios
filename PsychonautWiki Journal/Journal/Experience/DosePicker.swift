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

struct DosePicker: View {

    let roaDose: RoaDose?
    @Binding var doseMaybe: Double?
    @Binding var selectedUnits: String?
    var focusOnAppear = false
    @State private var doseText = ""
    @State private var dose: Double = 0
    @FocusState private var isDoseFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            let areUnitsDefined = roaDose?.units != nil
            if !areUnitsDefined {
                UnitsPicker(units: $selectedUnits)
                    .padding(.bottom, 10)
            }
            if areUnitsDefined {
                dynamicDoseRangeView
            }
            doseTextFieldWithUnit
        }
        .task {
            if focusOnAppear {
                isDoseFieldFocused = true
            }
            if let doseUnwrapped = doseMaybe {
                doseText = doseUnwrapped.formatted()
                dose = doseUnwrapped
            }
        }
    }

    var doseType: DoseRangeType {
        guard let selectedUnits = selectedUnits else {
            return .none
        }
        return roaDose?.getRangeType(for: dose, with: selectedUnits) ?? .none
    }

    private var doseTextFieldWithUnit: some View {
        HStack {
            TextField("Enter Dose", text: $doseText)
                .focused($isDoseFieldFocused)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(doseType.color)
            Text(selectedUnits ?? "")
        }
        .font(.title)
        .onChange(of: doseText) { _ in
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            if let doseUnwrapped = formatter.number(from: doseText)?.doubleValue {
                dose = doseUnwrapped
                doseMaybe = doseUnwrapped
            } else {
                doseMaybe = nil
            }
        }
    }

    private var dynamicDoseRangeView: some View {
        let units = roaDose?.units ?? ""
        if let threshold = roaDose?.lightMin,
           threshold > dose {
            return Text("threshold (\(threshold.formatted()) \(units))")
                .foregroundColor(DoseRangeType.thresh.color)
        } else if let lightMin = roaDose?.lightMin,
                  let lightMax = roaDose?.commonMin,
                  dose >= lightMin && dose < lightMax {
            return Text("light (\(lightMin.formatted()) - \(lightMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.light.color)
        } else if let commonMin = roaDose?.commonMin,
                  let commonMax = roaDose?.strongMin,
                  dose >= commonMin && dose < commonMax {
            return Text("common (\(commonMin.formatted()) - \(commonMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.common.color)
        } else if let strongMin = roaDose?.strongMin,
                  let strongMax = roaDose?.heavyMin,
                  dose >= strongMin && dose < strongMax {
            return Text("strong (\(strongMin.formatted()) - \(strongMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.strong.color)
        } else if let heavyMin = roaDose?.heavyMin,
                  dose >= heavyMin {
            return Text("heavy (\(heavyMin.formatted()) \(units)+)")
                .foregroundColor(DoseRangeType.heavy.color)
        } else {
            return Text(" ")
        }
    }
}
