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

struct TimelineDisclaimers: View {

    let isShowingOralDisclaimer: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("* Heavy doses can have longer durations.")
            if isShowingOralDisclaimer {
                Text("* A full stomach may delay the onset of oral doses by ~3 hours.")
                Text("* Hard (two-piece) capsules may need up to one hour to dissolve fully.")
            }
        }.font(.footnote).maybeCondensed()
    }
}

struct TimelineDisclaimers_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TimelineDisclaimers(isShowingOralDisclaimer: true)
        }
    }
}
