//
//  EditExperience.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct EditExperience: View {

    @State private var notes = ""

    var body: some View {
        Form {
            Section {
                TextEditor(text: $notes)
                    .frame(minHeight: 300)
            }
        }
    }
}

struct EditExperience_Previews: PreviewProvider {
    static var previews: some View {
        EditExperience()
    }
}
