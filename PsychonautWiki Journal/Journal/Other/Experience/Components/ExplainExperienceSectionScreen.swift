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

struct ExplainExperienceSectionScreen: View {
    var body: some View {
        List {
            Section("Simplifying Assumptions") {
                Text("To be able to draw the timeline with the given data multiple often false simplifying assumptions are made:")
                Text("\"Taking e.g. x amount now will give the same effect as taking x amount later. There is no immediate tolerance.\"")
                Text("\"Taking twice the dose will give twice the effect.\"")
                Text("\"Duration ranges from PsychonautWiki can be applied for all kinds of dosages.\"")
                Text("\"Oral ingestions are always on an empty stomach and therefore not delayed (by up to 4 hours).\"")
            }
            Section("Understanding the Timeline") {
                TimelineExplanationTexts()
                if #available(iOS 16.2, *) {
                    Text("The start live activity button shows the timeline on the lockscreen.")
                }
            }
            Section("Dosage Dots") {
                Text("The dots below the dose of an ingestion indicate the strength of the dose. 0 dots means the dose is below threshold, 1 light, 2 common, 3 strong and 4 heavy. More than 4 dots appear when a dose is heavy and the remainder from subtracting the start of the heavy dose range classifies as a light, common, strong or heavy.")
            }
        }
        .navigationTitle("Timeline Info")
    }
}

struct TimelineExplanationTexts: View {
    var body: some View {
        Group {
            Text("The timeline is drawn based on the onset, comeup, peak and offset (and sometimes total) from PsychonautWiki.")
            Text("In the ideal case all 4 durations (onset, comeup, peak and offset) are defined and the full timeline is drawn as averageOnset -> averageComeup -> weightedPeak -> weightedOffset, where \"weighted\" means that the given range has been linearly interpolated with the dose, so if a threshold dose was taken it takes the minimum of the range, if a heavy dose was taken it takes the max and for everything in between it linearly interpolates.")
            Text("The timelines from ingestions with the same substance and administration route where substances have onset, comeup, peak and offset defined are combined into a cumulative timeline by simply putting the individual lines on top of each other. This is not done for substances/routes where either the onset, comeup, peak or offset duration is missing or if the \"draw redoses individually\" toggle in settings is enabled.")
            Text("If any of the 4 durations are missing but the total duration is given, then the first defined durations are drawn and as soon as a missing duration is encountered it uses the total to infer the end of the timeline and draws a dotted line to the end. If the total is not given it just stops drawing the line. So if there is no timeline or part of the timeline is missing that means that the duration is not defined in PsychonautWiki. If you add the missing durations in PsychonautWiki, the full timeline will be shown in the next update.")
            Text("Different administration routes are always drawn as separate timelines even if they are of the same substance.")
            Text("By default the logic of how high the timeline is, is as follows: all ingestions are converted to a normalized dose which is 1 for the average of the common dose range. 1.5 would mean 1.5 times the common dose. Unknown doses are estimated as 1 = common dose. Doses where there is no PW dose range as e.g. for custom substances or other routes of administration take the average of the doses in the experience as the common dose. This allows to not only compare doses of ingestions of the same substance and route of administration but also compare ingestions of different substances. The ingestion or cumulative timeline with the highest normalized dose in the experience always takes the full height. The other ingestions are sized relative to that one.")
            Text("If the \"independent substance height\" toggle in settings is enabled then each substance takes the full height regardless of its dose strength relative to other substances in the same timeline.")
            Text("If you see a dotted line that means it is not known how the effect develops over that timeframe. The only thing that is known is approximately where the line will end.")
            Text("When a time range is given for the ingestion and all durations are defined for the route of administration then the app assumes the dosage was evenly consumed in that time frame and cumulates the curves of the infinitesimal ingestions using convolution.")
        }
    }
}

#Preview {
    NavigationStack {
        ExplainExperienceSectionScreen()
    }
}
