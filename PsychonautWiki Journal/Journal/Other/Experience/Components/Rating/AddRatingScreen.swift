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

struct AddRatingScreen: View {
    let experience: Experience
    let canDefineOverall: Bool
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime = Date.now
    @State private var selectedRating = ShulginRatingOption.twoPlus
    @State private var isOverallRating = false
    @EnvironmentObject private var toastViewModel: ToastViewModel

    var body: some View {
        NavigationStack {
            screen.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    doneButton
                }
            }
        }
        .onAppear {
            if experience.isCurrent {
                selectedTime = Date()
            } else {
                selectedTime = experience.sortDateUnwrapped.addingTimeInterval(30 * 60)
            }
        }
    }

    var doneButton: some View {
        DoneButton {
            save()
            toastViewModel.showSuccessToast(message: "Rating Added")
            dismiss()
        }
    }

    var screen: some View {
        RatingScreenContent(
            selectedTime: $selectedTime,
            selectedRating: $selectedRating,
            canDefineOverall: canDefineOverall,
            isOverallRating: $isOverallRating
        )
        .navigationTitle("Add Shulgin Rating")
    }

    func save() {
        let context = PersistenceController.shared.viewContext
        let newRating = ShulginRating(context: context)
        newRating.creationDate = Date()
        if canDefineOverall && isOverallRating {
            newRating.time = nil
        } else {
            newRating.time = selectedTime
        }
        newRating.option = selectedRating.rawValue
        newRating.experience = experience
        try? context.save()
    }
}
