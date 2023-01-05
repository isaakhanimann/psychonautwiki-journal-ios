//
//  ExperiencePickerScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

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
