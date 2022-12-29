//
//  EditExperience.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct EditExperienceScreen: View {

    let experience: Experience
    let dismissToJournalScreen: () -> Void
    @State private var title = ""
    @State private var notes = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditExperienceContent(
            title: $title,
            notes: $notes,
            save: save,
            delete: delete
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

    private func delete() {
        PersistenceController.shared.viewContext.delete(experience)
        PersistenceController.shared.saveViewContext()
        dismiss()
        dismissToJournalScreen()
    }
}

struct EditExperienceContent: View {

    @Binding var title: String
    @Binding var notes: String
    let save: () -> Void
    let delete: () -> Void
    @State private var isShowingDeleteAlert = false

    var body: some View {
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
            Section("Delete") {
                Button {
                    isShowingDeleteAlert.toggle()
                } label: {
                    Label("Delete Experience", systemImage: "trash").foregroundColor(.red)
                }
                .alert(isPresented: $isShowingDeleteAlert) {
                    Alert(
                        title: Text("Delete Experience?"),
                        message: Text("This will also delete all of its ingestions."),
                        primaryButton: .destructive(Text("Delete"), action: delete),
                        secondaryButton: .cancel()
                    )
                }
            }
        }.navigationTitle("Edit Experience")
            .toolbar {
                ToolbarItem {
                    Button("Done", action: save)
                }
            }
    }
}

struct EditExperienceContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditExperienceContent(
                title: .constant("This is my title"),
                notes: .constant("These are my notes. They can be very long and should work with many lines. If this should be editable then create a view inside this preview struct that has state."),
                save: {},
                delete: {}
            )
        }
    }
}
