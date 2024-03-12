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
import WrappingHStack

struct SearchSubstanceRow: View {
    let substance: Substance

    var body: some View {
        NavigationLink(value: GlobalNavigationDestination.substance(substance: substance)) {
            VStack(alignment: .leading) {
                Text(substance.name).font(.headline)
                let commonNames = substance.commonNames.joined(separator: ", ")
                if !commonNames.isEmpty {
                    Text(commonNames).font(.subheadline).foregroundColor(.secondary)
                }
                Spacer().frame(height: 5)
                WrappingHStack(
                    alignment: .leading,
                    horizontalSpacing: 3,
                    verticalSpacing: 3
                ) {
                    ForEach(substance.categories, id: \.self) { category in
                        Chip(name: category)
                    }
                }
            }
        }
    }
}

struct Chip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color(.systemGray5))
            .cornerRadius(12)
    }
}

#Preview {
    List {
        SearchSubstanceRow(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!)
    }.listStyle(.plain)
}
