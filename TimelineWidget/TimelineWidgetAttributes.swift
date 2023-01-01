//
//  TimelineWidgetAttributes.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 01.01.23.
//

import ActivityKit

struct TimelineWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public static func == (lhs: TimelineWidgetAttributes.ContentState, rhs: TimelineWidgetAttributes.ContentState) -> Bool {
            lhs.everythingForEachLine == rhs.everythingForEachLine
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(everythingForEachLine.description)
        }

        // Dynamic stateful properties about your activity go here!
        var everythingForEachLine: [EverythingForOneLine]
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
