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

struct EditExperienceScreen: View {

    let experience: Experience
    @State private var title = ""
    @State private var notes = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditExperienceContent(
            title: $title,
            notes: $notes,
            save: save,
            dismiss: {dismiss()}
        )
        .onAppear {
            title = experience.titleUnwrapped
            notes = experience.textUnwrapped
        }
    }

    private func save() {
        experience.title = title
        experience.text = notes
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}

struct EditExperienceContent: View {

    @Binding var title: String
    @Binding var notes: String
    let save: () -> Void
    let dismiss: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Enter Title", text: $title)
                        .autocapitalization(.sentences)
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .autocapitalization(.sentences)
                        .frame(minHeight: 300)
                }
            }
            .navigationTitle("Edit Experience")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: dismiss)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: save)
                }
            }
        }
    }
}

struct EditExperienceContent_Previews: PreviewProvider {
    static var previews: some View {
        EditExperienceContent(
            title: .constant("This is my title"),
            notes: .constant("These are my notes. They can be very long and should work with many lines. If this should be editable then create a view inside this preview struct that has state."),
            save: {},
            dismiss: {}
        )
    }
}
