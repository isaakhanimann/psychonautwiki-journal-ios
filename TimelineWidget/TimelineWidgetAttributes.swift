//
//  TimelineWidgetAttributes.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 01.01.23.
//

import ActivityKit

struct TimelineWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var value: Int
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
