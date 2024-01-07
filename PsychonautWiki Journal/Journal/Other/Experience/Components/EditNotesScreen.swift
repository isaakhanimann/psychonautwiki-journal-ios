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

struct EditNotesScreen: View {
    let experience: Experience

    @FocusState private var isTextFieldFocused: Bool
    @State private var notes = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditNotesContent(
            notes: $notes,
            isTextFieldFocused: $isTextFieldFocused,
            save: save,
            dismiss: { dismiss() }
        )
        .onAppear {
            notes = experience.textUnwrapped
            if experience.textUnwrapped.isEmpty {
                isTextFieldFocused = true
            }
        }
    }

    private func save() {
        experience.text = notes
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}

struct EditNotesContent: View {
    @Binding var notes: String
    let isTextFieldFocused: FocusState<Bool>.Binding
    let save: () -> Void
    let dismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextEditor(text: $notes)
                    .focused(isTextFieldFocused)
                    .autocapitalization(.sentences)
                    .frame(minHeight: 300)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    DoneButton {
                        save()
                    }
                }
            }
        }
    }
}

// previews don't work because can't pass FocusState
