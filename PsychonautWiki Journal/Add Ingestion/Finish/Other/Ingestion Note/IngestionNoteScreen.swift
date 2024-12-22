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

struct IngestionNoteScreen: View {
    @Binding var note: String
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        NavigationStack {
            screen.toolbar {
                ToolbarItem(placement: .primaryAction) {
                    doneButton
                }
            }
        }
        .onAppear {
            textFieldIsFocused = true
        }
    }

    private var doneButton: some View {
        DoneButton {
            dismiss()
        }
    }

    private var screen: some View {
        Form {
            TextField("Enter Note", text: $note, axis: .vertical)
                .onSubmit {
                    dismiss()
                }
                .submitLabel(.done)
                .focused($textFieldIsFocused)
                .autocapitalization(.sentences)
            if !viewModel.suggestedNotesInOrder.isEmpty {
                Section("Suggestions") {
                    ForEach(viewModel.suggestedNotesInOrder, id: \.self) { suggestedNote in
                        Button {
                            note = suggestedNote
                        } label: {
                            Label(suggestedNote, systemImage: "doc.on.doc").lineLimit(1)
                        }.foregroundColor(.primary)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Ingestion Note")
    }
}

#Preview {
    NavigationStack {
        IngestionNoteScreen(note: .constant(""))
    }
}
