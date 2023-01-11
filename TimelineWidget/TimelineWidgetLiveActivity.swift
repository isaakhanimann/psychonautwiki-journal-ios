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
import WidgetKit
import SwiftUI

struct TimelineWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimelineWidgetAttributes.self) { context in
            let timelineModel = TimelineModel(everythingForEachLine: context.state.everythingForEachLine)
            let totalHeight = 160.0 // in the documentation: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities it says that truncation only happens if the height exceeds 160 points
            let verticalPadding = 15.0
            EffectTimeline(
                timelineModel: timelineModel,
                height: totalHeight - verticalPadding,
                isShowingCurrentTime: false,
                spaceToLabels: 7
            )
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 10)
        } dynamicIsland: { context in
            let timelineModel = TimelineModel(everythingForEachLine: context.state.everythingForEachLine)
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
            .widgetURL(URL(string: OpenJournalURL))
        }
    }
}

struct TimelineWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = TimelineWidgetAttributes(name: "Me")
    static let contentState = TimelineWidgetAttributes.ContentState(everythingForEachLine: EffectTimeline_Previews.everythingForEachLine)

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
