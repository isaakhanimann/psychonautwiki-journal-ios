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

struct TimedNoteRow<Content: View>: View {
    @ObservedObject var timedNote: TimedNote
    @ViewBuilder var timeText: Content

    var body: some View {
        TimedNoteRowContent(
            note: timedNote.noteUnwrapped,
            color: timedNote.color,
            isPartOfTimeline: timedNote.isPartOfTimeline
        ) {
            timeText
        }
    }
}

private struct TimedNoteRowContent<Content: View>: View {
    let note: String
    let color: SubstanceColor
    let isPartOfTimeline: Bool
    @ViewBuilder var timeText: Content

    var body: some View {
        HStack {
            Group {
                if isPartOfTimeline {
                    TimedNoteDottedLine(color: color.swiftUIColor)
                } else {
                    Spacer().frame(width: StrokeStyle.timedNoteLineWidth)
                }
            }
            .padding(.vertical, 8)
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    timeText.font(.headline)
                    if !isPartOfTimeline {
                        Text(" (not part of timeline)").font(.footnote).foregroundColor(.secondary)
                    }
                }

                Text(note).font(.subheadline)
            }
        }
    }
}

#Preview {
    List {
        TimedNoteRowContent(
            note: "Your note",
            color: .blue,
            isPartOfTimeline: true
        ) {
            Text("Sat 7:37")
        }
        TimedNoteRowContent(
            note: "Your note",
            color: .blue,
            isPartOfTimeline: false
        ) {
            Text("Sat 7:37")
        }
    }
}
