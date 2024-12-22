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

struct EditTitleScreen: View {
    let experience: Experience

    @State private var title = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditTitleScreenContent(
            title: $title,
            isTextFieldFocused: $isTextFieldFocused,
            save: save,
            dismiss: { dismiss() }
        )
        .onAppear {
            title = experience.titleUnwrapped
            isTextFieldFocused = true
        }
    }

    private func save() {
        experience.title = title
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}

struct EditTitleScreenContent: View {
    @Binding var title: String
    let isTextFieldFocused: FocusState<Bool>.Binding
    let save: () -> Void
    let dismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Title", text: $title, axis: .vertical)
                    .onSubmit {
                        save()
                    }
                    .submitLabel(.done)
                    .focused(isTextFieldFocused)
                    .autocapitalization(.sentences)
                    .autocorrectionDisabled()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Title")
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

// can't have preview because can't pass FocusState
