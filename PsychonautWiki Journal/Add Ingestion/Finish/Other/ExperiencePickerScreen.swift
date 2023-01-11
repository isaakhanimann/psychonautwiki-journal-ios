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

struct ExperiencePickerScreen: View {
    @Binding var selectedExperience: Experience?
    let experiences: [Experience]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section {
                ForEach(experiences) { exp in
                    button(for: exp)
                }
            }.headerProminence(.increased)
        }.navigationTitle("Choose Experience")
    }

    private func button(for exp: Experience) -> some View {
        Button {
            selectedExperience = exp
            dismiss()
        } label: {
            if selectedExperience == exp {
                HStack {
                    Text(exp.titleUnwrapped)
                    Spacer()
                    Image(systemName: "checkmark")
                }
            } else {
                Text(exp.titleUnwrapped)
            }
        }

    }
}
