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

struct ChooseDateScreen: View {

    let substanceName: String
    let cancel: () -> Void
    let finish: (SubstanceAndDay) -> Void

    @State private var date = Date()

    var body: some View {
        Form {
            DatePicker("Ingestion Date",
                       selection: $date,
                       displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    cancel()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                DoneButton {
                    finish(SubstanceAndDay(substanceName: substanceName, day: date))
                }
            }
        }
        .navigationTitle("Choose Date")
    }
}

struct ChooseDateScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseDateScreen(
                substanceName: "Hello",
                cancel: {},
                finish: { _ in }
            )
        }
    }
}
