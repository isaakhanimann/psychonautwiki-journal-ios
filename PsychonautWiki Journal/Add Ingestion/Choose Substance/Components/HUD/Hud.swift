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

struct HUD<Content: View>: View {
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color(colorScheme == .dark ? .white : .black).opacity(0.16), radius: 12, x: 0, y: 5)
    }
}
