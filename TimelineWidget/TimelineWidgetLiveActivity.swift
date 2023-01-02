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
            return GeometryReader { geo in
                EffectTimeline(
                    timelineModel: timelineModel,
                    height: geo.size.height
                )
            }
        } dynamicIsland: { context in
            let timelineModel = TimelineModel(everythingForEachLine: context.state.everythingForEachLine)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "arrow.backward.to.line")
                        Text(timelineModel.startTime, style: .timer)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Text(timerInterval: Date.now...Date(timeInterval: timelineModel.totalWidth, since: timelineModel.startTime))
                        Image(systemName: "arrow.forward.to.line")
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    GeometryReader { geo in
                        EffectTimeline(
                            timelineModel: timelineModel,
                            height: geo.size.height
                        )
                    }
                }
            } compactLeading: {
                HStack {
                    Image(systemName: "arrow.backward.to.line")
                    Text(timelineModel.startTime, style: .timer)
                }
            } compactTrailing: {
                HStack {
                    Text(timerInterval: Date.now...Date(timeInterval: timelineModel.totalWidth, since: timelineModel.startTime))
                    Image(systemName: "arrow.forward.to.line")
                }
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
