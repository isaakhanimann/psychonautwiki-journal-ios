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

struct RatingScreenContent: View {

    @Binding var selectedTime: Date
    @Binding var selectedRating: ShulginRatingOption

    var body: some View {
        Form {
            Section("Time") {
                DatePicker(
                    "Ingestion Time",
                    selection: $selectedTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
            }
            Section("Shulgin Rating") {
                Picker("Shulgin Rating", selection: $selectedRating) {
                    ForEach(ShulginRatingOption.allCases, id: \.self) { option in
                        HStack {
                            Text(option.stringRepresentation).font(.title3)
                            Text("(\(option.shortDescription))").foregroundColor(.secondary).font(.caption)
                        }
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("Shulgin Rating Explanation") {
                ForEach(ShulginRatingOption.allCases, id: \.self) { option in
                    VStack(alignment: .leading) {
                        Text(option.stringRepresentation).font(.title3)
                        Text(option.description).foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct EditRatingScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        RatingScreenContent(
            selectedTime: .constant(.now),
            selectedRating: .constant(.plus)
        )
    }
}
