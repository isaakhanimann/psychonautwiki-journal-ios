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

struct FabLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            let circleWidth: Double = 54
            Circle()
                .fill(Color.accentColor)
                .frame(width: circleWidth, height: circleWidth)
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            Label(configuration)
                .labelStyle(.iconOnly)
                .font(.title.weight(.semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    Button {
    } label: {
        Label("New Ingestion", systemImage: "plus").labelStyle(FabLabelStyle())
    }
}
