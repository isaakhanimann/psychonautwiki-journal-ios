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
            TimedNoteDottedLine(color: color.swiftUIColor)
            VStack(alignment: .leading) {
                Group {
                    if timeDisplayStyle == .relativeToNow {
                        Text(time, style: .relative) + Text(" ago")
                    } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
                        Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: time)))
                    } else {
                        Text(time, format: Date.FormatStyle().hour().minute().weekday(.abbreviated))

                    }
                }
                .font(.headline)
                .foregroundColor(.primary)
                Text(note).font(.subheadline)
            }
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
        }
    }
}
