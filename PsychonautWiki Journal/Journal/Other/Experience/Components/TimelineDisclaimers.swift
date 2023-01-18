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

let HEAVY_DOSE_DISCLAIMER = "Heavy doses can have longer durations."
let FULL_STOMACH_DISCLAIMER = "A full stomach may delay the onset of oral doses by ~3 hours."
let CAPSULE_DISCLAIMER = "Hard (two-piece) capsules may need up to one hour to dissolve fully."

struct TimelineDisclaimers: View {

    let isShowingOralDisclaimer: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("* \(HEAVY_DOSE_DISCLAIMER)")
            if isShowingOralDisclaimer {
                Text("* \(FULL_STOMACH_DISCLAIMER)")
                Text("* \(CAPSULE_DISCLAIMER)")
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
