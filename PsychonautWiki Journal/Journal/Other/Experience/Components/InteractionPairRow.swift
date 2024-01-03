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

struct InteractionPairRow: View {
    let aName: String
    let bName: String
    let interactionType: InteractionType

    var body: some View {
        HStack(spacing: 0) {
            Text(aName).lineLimit(1)
            Spacer()
            Image(systemName: "arrow.left.arrow.right")
            Spacer()
            Text(bName).lineLimit(1)
            Spacer()
            ForEach(0 ..< interactionType.dangerCount, id: \.self) { _ in
                Image(systemName: "exclamationmark.triangle")
            }
        }.foregroundColor(interactionType.color)
    }
}

#Preview {
    List {
        InteractionPairRow(
            aName: "Amphetamine with a long name",
            bName: "Tramadol",
            interactionType: .dangerous
        )
    }
}
