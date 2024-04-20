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

struct FabPosition<Screen: View, Button: View>: View {
    @ViewBuilder let button: Button
    @ViewBuilder let screen: Screen

    var body: some View {
        ZStack(alignment: .bottom) {
            screen
            button.padding(20)
        }
    }
}

#Preview {
    FabPosition {
        Button {} label: {
            Label("New Ingestion", systemImage: "plus")
                .labelStyle(FabLabelStyle())
        }
    } screen: {
        Color.gray.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
