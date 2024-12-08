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

struct DotRows: View {
    let numDots: Int

    var body: some View {
        VStack(spacing: 0) {
            if numDots == 0 {
                HStack(spacing: 0) {
                    ForEach(1 ... 4, id: \.self) { _ in
                        Dot(isFull: false)
                    }
                }
            } else if numDots > 20 {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(numDots)x")
                    Dot(isFull: true)
                }
            } else {
                let numFullRows = numDots / 4
                let dotsInLastRow = numDots % 4
                if numFullRows > 0 {
                    ForEach(1 ... numFullRows, id: \.self) { _ in
                        HStack(spacing: 0) {
                            ForEach(1 ... 4, id: \.self) { _ in
                                Dot(isFull: true)
                            }
                        }
                    }
                }
                if dotsInLastRow > 0 {
                    HStack(spacing: 0) {
                        ForEach(1 ... dotsInLastRow, id: \.self) { _ in
                            Dot(isFull: true)
                        }
                        let numEmpty = 4 - dotsInLastRow
                        ForEach(1 ... numEmpty, id: \.self) { _ in
                            Dot(isFull: false)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DotRows(numDots: 3)
}
