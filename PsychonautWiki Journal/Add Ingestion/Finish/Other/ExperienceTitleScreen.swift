//
//  ExperienceTitleScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.01.23.
//

import SwiftUI

struct ExperienceTitleScreen: View {
    @Binding var title: String
    @Environment(\.dismiss) var dismiss
    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        Form {
            TextField("Enter Title", text: $title)
                .onSubmit {
                    dismiss()
                }
                .submitLabel(.done)
                .focused($textFieldIsFocused)
                .autocapitalization(.sentences)
        }
        .optionalScrollDismissesKeyboard()
        .navigationTitle("Experience Title")
        .onAppear {
            textFieldIsFocused = true
        }
    }
}

struct ExperienceTitleScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExperienceTitleScreen(title: .constant(""))
        }
    }
}
