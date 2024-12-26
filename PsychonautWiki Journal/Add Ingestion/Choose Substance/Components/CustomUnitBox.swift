// Copyright (c) 2024. Isaak Hanimann.
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

struct CustomUnitBox: View {

    let customUnit: CustomUnit

    var body: some View {
        NavigationLink(value: customUnit) {
            NavigatableListItemContent(
                title: "\(customUnit.substanceNameUnwrapped), \(customUnit.nameUnwrapped)") {
                    Text("\(customUnit.doseOfOneUnitDescription) per \(customUnit.unitUnwrapped)")
                }
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

struct NavigatableListItemContent<Description: View>: View {

    let title: String
    @ViewBuilder let description: () -> Description

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.headline).multilineTextAlignment(.leading)
                description()
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.forward")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}


#Preview {
    NavigationStack {
        CustomUnitBox(customUnit: .previewSample)
        CustomUnitBox(customUnit: .previewSample)
    }
}
