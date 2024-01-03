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

struct MDMAMaxDoseCalculator: View {
    let onChangeOfMax: (Double) -> Void
    @State private var bodyWeightInKg = 75.0
    @State private var gender = Gender.male
    private var suggestedMaxDoseInMg: Double {
        bodyWeightInKg * gender.mgPerKg
    }

    private var suggestedMaxDoseRounded: Double {
        round(suggestedMaxDoseInMg)
    }

    private var suggestedDoseText: String {
        "\(Int(suggestedMaxDoseRounded)) mg"
    }

    enum Gender {
        case male
        case female

        var mgPerKg: Double {
            switch self {
            case .male:
                return 1.5
            case .female:
                return 1.3
            }
        }
    }

    var body: some View {
        VStack {
            Text(suggestedDoseText).font(.title.bold())
            Picker("Gender", selection: $gender) {
                Text("Male").tag(Gender.male)
                Text("Female").tag(Gender.female)
            }.pickerStyle(.segmented)
            Text("\(Int(bodyWeightInKg)) kg").font(.title2.bold())
            Slider(
                value: $bodyWeightInKg,
                in: 40 ... 150,
                step: 5
            ) {
                Text("Body Weight")
            } minimumValueLabel: {
                Text("40")
            } maximumValueLabel: {
                Text("150")
            }
        }
        .onChange(of: bodyWeightInKg) { _ in
            onChangeOfMax(suggestedMaxDoseRounded)
        }
        .onChange(of: gender) { _ in
            onChangeOfMax(suggestedMaxDoseRounded)
        }
    }
}

#Preview {
    List {
        MDMAMaxDoseCalculator(onChangeOfMax: { _ in })
    }
}
