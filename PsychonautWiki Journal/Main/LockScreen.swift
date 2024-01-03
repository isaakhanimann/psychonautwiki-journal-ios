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

struct LockScreen: View {
    let isEyeOpen: Bool
    let isFaceIDEnabled: Bool
    var body: some View {
        VStack(spacing: 0) {
            Image(decorative: isEyeOpen ? "Eye Open" : "Eye Closed")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150, alignment: .top)
            if !isFaceIDEnabled {
                Spacer().frame(height: 20)
                Text("Face ID is disabled.\nEnable it for Journal in settings to unlock the app.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    LockScreen(isEyeOpen: false, isFaceIDEnabled: false)
}
