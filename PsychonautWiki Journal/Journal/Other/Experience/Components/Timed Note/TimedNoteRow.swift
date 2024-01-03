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

struct TimedNoteRow: View {
    @ObservedObject var timedNote: TimedNote
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?

    var body: some View {
        TimedNoteRowContent(
            time: timedNote.timeUnwrapped,
            note: timedNote.noteUnwrapped,
            color: timedNote.color,
            isPartOfTimeline: timedNote.isPartOfTimeline,
            timeDisplayStyle: timeDisplayStyle,
            firstIngestionTime: firstIngestionTime
        )
    }
}

private struct TimedNoteRowContent: View {
    let time: Date
    let note: String
    let color: SubstanceColor
    let isPartOfTimeline: Bool
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?

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
                timeText.font(.headline) + Text(isPartOfTimeline ? "" : " (not part of timeline)").font(.footnote).foregroundColor(.secondary)

                Text(note).font(.subheadline)
            }
        }
    }

    private var timeText: Text {
        if timeDisplayStyle == .relativeToNow {
            return Text(time, style: .relative) + Text(" ago")
        } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
            return Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: time)))
        } else {
            return Text(time, format: Date.FormatStyle().hour().minute().weekday(.abbreviated))
        }
    }
}

struct TimedNoteRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TimedNoteRowContent(
                time: .now,
                note: "My note",
                color: .blue,
                isPartOfTimeline: true,
                timeDisplayStyle: .regular,
                firstIngestionTime: nil
            )
            TimedNoteRowContent(
                time: .now,
                note: "My note",
                color: .blue,
                isPartOfTimeline: false,
                timeDisplayStyle: .regular,
                firstIngestionTime: nil
            )
        }
    }
}
