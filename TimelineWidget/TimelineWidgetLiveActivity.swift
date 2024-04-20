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

import ActivityKit
import SwiftUI
import WidgetKit

struct TimelineWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimelineWidgetAttributes.self) { context in
            let timelineModel = TimelineModel(
                substanceGroups: context.state.substanceGroups,
                everythingForEachRating: context.state.everythingForEachRating,
                everythingForEachTimedNote: context.state.everythingForEachTimedNote,
                areRedosesDrawnIndividually: context.state.areRedosesDrawnIndividually
            )
            VStack(spacing: 0) {
                GeometryReader { geo in
                    EffectTimeline(
                        timelineModel: timelineModel,
                        height: geo.size.height,
                        timeDisplayStyle: .regular, 
                        isShowingCurrentTime: false,
                        spaceToLabels: 7
                    )
                }
                .padding(.bottom, 3)
                ProgressView(
                    timerInterval: timelineModel.startTime ... timelineModel.startTime.addingTimeInterval(timelineModel.totalWidth),
                    countsDown: false
                )
                .progressViewStyle(.linear)
            }
            .padding(.top, 8)
            .padding(.bottom, 6)
            .padding(.horizontal, 10)
            .widgetURL(URL(string: openLatestExperience))
            .frame(height: 160) // in the documentation: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities it says that truncation only happens if the height exceeds 160 points
        } dynamicIsland: { context in
            let timelineModel = TimelineModel(
                substanceGroups: context.state.substanceGroups,
                everythingForEachRating: context.state.everythingForEachRating,
                everythingForEachTimedNote: context.state.everythingForEachTimedNote,
                areRedosesDrawnIndividually: context.state.areRedosesDrawnIndividually
            )
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(timelineModel.startTime, style: .relative)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(Date(timeInterval: timelineModel.totalWidth, since: timelineModel.startTime), style: .relative)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EffectTimeline(
                        timelineModel: timelineModel,
                        height: 90,
                        timeDisplayStyle: .regular, 
                        isShowingCurrentTime: false,
                        spaceToLabels: 7
                    )
                    .padding(.horizontal, 5)
                }
            } compactLeading: {
                Text(timelineModel.startTime, style: .relative)
            } compactTrailing: {
                Text(Date(timeInterval: timelineModel.totalWidth, since: timelineModel.startTime), style: .relative)
            } minimal: {
                Image(systemName: "eye")
            }
            .contentMargins(.bottom, 13, for: .expanded)
            .widgetURL(URL(string: openLatestExperience))
        }
    }
}

struct TimelineWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = TimelineWidgetAttributes(name: "Me")
    static let contentState = TimelineWidgetAttributes.ContentState(
        substanceGroups: EffectTimeline_Previews.substanceGroups,
        everythingForEachRating: EffectTimeline_Previews.everythingForEachRating,
        everythingForEachTimedNote: EffectTimeline_Previews.everythingForEachTimedNote,
        areRedosesDrawnIndividually: false
    )

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
