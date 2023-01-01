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
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                context.stroke(
                    path,
                    with: .color(.blue),
                    lineWidth: 5
                )
            }
            .activityBackgroundTint(Color(uiColor: .systemBackground))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading" + String(context.state.value))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing" + String(context.state.value))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Canvas { context, size in
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        context.stroke(
                            path,
                            with: .color(.blue),
                            lineWidth: 5
                        )
                    }
                }
            } compactLeading: {
                let a = String(context.state.value)
                Text("L" + a)
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct TimelineWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = TimelineWidgetAttributes(name: "Me")
    static let contentState = TimelineWidgetAttributes.ContentState(value: 3)

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
