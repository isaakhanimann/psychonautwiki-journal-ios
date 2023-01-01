//
//  TimelineWidgetBundle.swift
//  TimelineWidget
//
//  Created by Isaak Hanimann on 31.12.22.
//

import WidgetKit
import SwiftUI

@main
struct TimelineWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimelineWidget()
        TimelineWidgetLiveActivity()
    }
}
