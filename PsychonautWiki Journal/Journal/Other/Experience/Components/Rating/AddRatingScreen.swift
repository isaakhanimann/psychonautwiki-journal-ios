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
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime = Date.now
    @State private var selectedRating = ShulginRatingOption.twoPlus

    var body: some View {
        NavigationView {
            RatingScreenContent(
                selectedTime: $selectedTime,
                selectedRating: $selectedRating
            )
            .navigationTitle("Add Rating")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        save()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if experience.isCurrent {
                selectedTime = Date()
            } else {
                selectedTime = experience.sortDateUnwrapped.addingTimeInterval(30*60)
            }
        }
    }

    func save() {
        let context = PersistenceController.shared.viewContext
        let newRating = ShulginRating(context: context)
        newRating.creationDate = Date()
        newRating.time = selectedTime
        newRating.option = selectedRating.rawValue
        newRating.experience = experience
        try? context.save()
    }
}
