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
    @Binding var wantsToForceNewExperience: Bool
    let experiences: [Experience]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section("Create New") {
                Button {
                    selectedExperience = nil
                    wantsToForceNewExperience = true
                    dismiss()
                } label: {
                    let label = "Create New Experience"
                    if selectedExperience == nil {
                        HStack {
                            Text(label)
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    } else {
                        Text(label)
                    }
                }
            }
            Section("Close Experiences") {
                ForEach(experiences) { exp in
                    Button {
                        selectedExperience = exp
                        wantsToForceNewExperience = false
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
        }.navigationTitle("Choose Experience")
    }
}
