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
            Section("Caution") {
                Text(HEAVY_DOSE_DISCLAIMER)
                Text(FULL_STOMACH_DISCLAIMER)
                Text(CAPSULE_DISCLAIMER)
            }
            Section("Timeline") {
                Text("The timeline shows the effect of ingestions over time.")
                Text("The onset duration range from PsychonautWiki defines when the curve starts going up, the comeup how long it goes up for, the peak how long it stays up and the offset how long it takes to come down to baseline. The peak and offset durations are linearly interpolated based on the dose if possible, else it just chooses the middle value of the range. If some of the durations are missing it draws a dotted line. E.g. if the onset and total time is given it draws a line along the bottom for the onset and then it draws a dotted curve to the end of the total time.")
                Text("The height of a curve indicates how big the dose is relative to other ingestions of the same substance within the experience. If there is only one ingestion it takes the full height.")
                Text("By swiping an ingestion row to the right one can hide an ingestion from the timeline, to make the other curves more visible.")
                if #available(iOS 16.2, *) {
                    Text("The start live activity button shows the timeline on the lockscreen.")
                }
            }
            Section("Dosage Dots") {
                Text("The dots below the dose of an ingestion indicate the strength of the dose. 0 dots means the dose is below threshold, 1 light, 2 common, 3 strong and 4 heavy. More than 4 dots appear when a dose is heavy and the remainder from subtracting the start of the heavy dose range classifies as a light, common, strong or heavy.")
            }
        }.navigationTitle("Info")
    }
}

struct ExplainExperienceSectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExplainExperienceSectionScreen()
        }
    }
}
