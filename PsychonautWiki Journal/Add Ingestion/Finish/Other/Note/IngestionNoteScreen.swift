//
//  IngestionNoteScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.01.23.
//

import SwiftUI

struct IngestionNoteScreen: View {

    @Binding var note: String
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var textFieldIsFocused: Bool
    
    var body: some View {
        NavigationView {
            List {
                if #available(iOS 16.0, *) {
                    TextField(
                        "Enter Note",
                        text: $note,
                        axis: .vertical
                    )
                    .focused($textFieldIsFocused)
                    .onSubmit {
                        dismiss()
                    }
                    .lineLimit(3)
                    .autocapitalization(.sentences)
                    .submitLabel(.done)
                } else {
                    TextField("Enter Note", text: $note)
                        .onSubmit {
                            dismiss()
                        }
                        .focused($textFieldIsFocused)
                        .autocapitalization(.sentences)
                        .submitLabel(.done)
                }
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
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Ingestion Note")
            .onAppear {
                textFieldIsFocused = true
            }
        }
    }
}

struct IngestionNoteScreen_Previews: PreviewProvider {
    static var previews: some View {
        IngestionNoteScreen(note: .constant(""))
    }
}
