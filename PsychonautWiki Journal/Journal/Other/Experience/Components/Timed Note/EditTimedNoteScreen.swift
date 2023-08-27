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

struct EditTimedNoteScreen: View {

    @ObservedObject var timedNote: TimedNote
    @ObservedObject var experience: Experience

    @Environment(\.dismiss) private var dismiss
    @State private var time = Date.now
    @State private var note = ""
    @State private var color = SubstanceColor.blue
    @State private var isPartOfTimeline = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var alreadyUsedColors: Set<SubstanceColor> = []
    @State private var otherColors: Set<SubstanceColor> = []
    @State private var isFirstAppear = true // needed because else state is reset when navigating back from color picker

    var body: some View {
        TimedNoteScreenContent(
            time: $time,
            note: $note,
            color: $color,
            isPartOfTimeline: $isPartOfTimeline,
            isTextFieldFocused: $isTextFieldFocused,
            alreadyUsedColors: alreadyUsedColors,
            otherColors: otherColors
        )
        .onAppear {
            if isFirstAppear {
                time = timedNote.timeUnwrapped
                note = timedNote.noteUnwrapped
                color = timedNote.color
                isPartOfTimeline = timedNote.isPartOfTimeline
                alreadyUsedColors = Set(experience.timedNotesSorted.map({$0.color}))
                otherColors = Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
                isFirstAppear = false
            }
        }
        .onDisappear {
            save()
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: delete) {
                    Label("Delete Note", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Edit Note")
        .dismissWhenTabTapped()
    }

    func save() {
        timedNote.time = time
        timedNote.note = note
        timedNote.colorAsText = color.rawValue
        timedNote.isPartOfTimeline = isPartOfTimeline
        PersistenceController.shared.saveViewContext()
    }

    func delete() {
        PersistenceController.shared.viewContext.delete(timedNote)
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}
