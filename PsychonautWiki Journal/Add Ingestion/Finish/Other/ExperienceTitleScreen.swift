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

struct ExperienceTitleScreen: View {
    @Binding var title: String
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
            TextField("Enter Title", text: $title)
                .onSubmit {
                    dismiss()
                }
                .submitLabel(.done)
                .focused($textFieldIsFocused)
                .autocapitalization(.sentences)
                .autocorrectionDisabled()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Experience Title")
    }
}

#Preview {
    NavigationStack {
        ExperienceTitleScreen(title: .constant(""))
    }
}
