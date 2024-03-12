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

struct EditOverallRatingScreen: View {
    @ObservedObject var rating: ShulginRating
    @Environment(\.dismiss) var dismiss
    @State private var selectedRating = ShulginRatingOption.twoPlus

    var body: some View {
        List {
            SelectRatingSection(selectedRating: $selectedRating)
            RatingExplanationSection()
            Button(action: delete) {
                Label("Delete Rating", systemImage: "trash").foregroundColor(.red)
            }
        }.onAppear {
            selectedRating = rating.optionUnwrapped
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
            }
        }
    }

    func save() {
        rating.option = selectedRating.rawValue
        PersistenceController.shared.saveViewContext()
    }

    func delete() {
        PersistenceController.shared.viewContext.delete(rating)
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}
