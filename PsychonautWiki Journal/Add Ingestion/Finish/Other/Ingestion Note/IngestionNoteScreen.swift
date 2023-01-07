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
        Form {
            TextField("Enter Note", text: $note)
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
        .optionalScrollDismissesKeyboard()
        .navigationTitle("Ingestion Note")
        .onAppear {
            textFieldIsFocused = true
        }
    }
}

struct IngestionNoteScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IngestionNoteScreen(note: .constant(""))
        }
    }
}
