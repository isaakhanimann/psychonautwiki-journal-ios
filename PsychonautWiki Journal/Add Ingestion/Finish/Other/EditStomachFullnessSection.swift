// Copyright (c) 2023. Isaak Hanimann.
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

struct EditStomachFullnessSection: View {

    @Binding var stomachFullness: StomachFullness

    var body: some View {
        Section("Stomach Fullness") {
            StomachFullnessPicker(stomachFullness: $stomachFullness)
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }
}

struct StomachFullnessPicker: View {

    @Binding var stomachFullness: StomachFullness

    var body: some View {
        Picker("Stomach Fullness", selection: $stomachFullness) {
            ForEach(StomachFullness.allCases) { option in
                HStack {
                    Text(option.text)
                    Spacer()
                    Text("~\(option.onsetDelayForOralInHours.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 1)) hours delay").foregroundColor(.secondary)
                }
            }
        }
    }
}


#Preview {
    List {
        EditStomachFullnessSection(stomachFullness: .constant(.empty))
    }
}
