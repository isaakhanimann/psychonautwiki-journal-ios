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

struct AddTimedNoteScreen: View {

    let experience: Experience

    @Environment(\.dismiss) private var dismiss
    @State private var time = Date.now
    @State private var note = ""
    @State private var color = SubstanceColor.blue
    @State private var isPartOfTimeline = false
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var alreadyUsedColors: Set<SubstanceColor> = []
    @State private var otherColors: Set<SubstanceColor> = []

    var body: some View {
        NavigationView {
            TimedNoteScreenContent(
                time: $time,
                note: $note,
                color: $color,
                isPartOfTimeline: $isPartOfTimeline,
                isTextFieldFocused: $isTextFieldFocused,
                alreadyUsedColors: alreadyUsedColors,
                otherColors: otherColors
            )
            .navigationTitle("Add Timed Note")
            .toolbar {
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
            isTextFieldFocused = true
            isPartOfTimeline = experience.isCurrent
            alreadyUsedColors = Set(experience.timedNotesSorted.map({$0.color}))
            otherColors = Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
            if let otherColor = otherColors.randomElement() {
                color = otherColor
            }
        }
    }

    var doneButton: some View {
        Button {
            save()
            toastViewModel.showSuccessToast(message: "Note Added")
            dismiss()
        } label: {
            Label("Done", systemImage: "checkmark.circle.fill").labelStyle(.titleAndIcon).font(.headline)
        }
    }

    func save() {
        let context = PersistenceController.shared.viewContext
        let newNote = TimedNote(context: context)
        newNote.creationDate = Date()
        newNote.time = time
        newNote.note = note
        newNote.colorAsText = color.rawValue
        newNote.isPartOfTimeline = isPartOfTimeline
        newNote.experience = experience
        try? context.save()
    }
}
