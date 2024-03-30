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

struct ExperienceTimeText: View {
    let time: Date
    let isTimeRelative: Bool
    let isCurrent: Bool

    var body: some View {
        if isCurrent {
            if time < .now {
                return Text("Active since ") + Text(time, style: .relative)
            } else {
                return Text(time, style: .relative)
            }
        } else {
            if isTimeRelative {
                return Text(time, format: .relative(presentation: .numeric, unitsStyle: .wide))
            } else {
                return Text(time, format: Date.FormatStyle().day().month().year().weekday(.abbreviated))
            }
        }
    }
}

#Preview {
    ExperienceTimeText(time: Date() - 5 * 60 * 60 - 30, isTimeRelative: false, isCurrent: true)
}
