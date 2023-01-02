//
//  TimelineWidgetLiveActivity.swift
//  TimelineWidget
//
//  Created by Isaak Hanimann on 31.12.22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimelineWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimelineWidgetAttributes.self) { context in
            let timelineModel = TimelineModel(everythingForEachLine: context.state.everythingForEachLine)
            let totalHeight = 160.0 // in the documentation: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities it says that truncation only happens if the height exceeds 160 points
            let bottomPadding = 3.0
            EffectTimeline(
                timelineModel: timelineModel,
                height: totalHeight - bottomPadding,
                isShowingCurrentTime: false
            ).padding(.bottom, bottomPadding)
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
                        isShowingCurrentTime: false
                    )

                }
            } compactLeading: {
                Text(timelineModel.startTime, style: .relative)
            } compactTrailing: {
                Text(Date(timeInterval: timelineModel.totalWidth, since: timelineModel.startTime), style: .relative)
            } minimal: {
                Image(systemName: "eye")
            }
            .contentMargins(.bottom, 13, for: .expanded)
            .widgetURL(URL(string: OpenExperienceURL))
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
