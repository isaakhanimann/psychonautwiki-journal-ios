//
//  LiveActivitySection.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 02.01.23.
//

import SwiftUI
import ActivityKit

@available(iOS 16.2, *)
struct LiveActivitySection: View {

    let stopLiveActivity: () -> Void
    let startLiveActivity: () -> Void
    @State private var areActivitiesEnabled = false
    @State private var isActivityActive = false

    var body: some View {
        Group {
            if areActivitiesEnabled {
                Section("Live Activity") {
                    if isActivityActive {
                        Button("Stop Live Activity", action: stopLiveActivity)
                    } else {
                        Button("Start Live Activity", action: startLiveActivity)
                    }
                }
            } else {
                Text("not enabled")
            }
        }.task {
            let authorizationInfo = ActivityManager.shared.authorizationInfo
            self.areActivitiesEnabled = authorizationInfo.areActivitiesEnabled
            for await isEnabled in authorizationInfo.activityEnablementUpdates {
                self.areActivitiesEnabled = isEnabled
            }
            guard let first = Activity<TimelineWidgetAttributes>.activities.first else {return}
            for await stateUpdate in first.activityStateUpdates {
                self.isActivityActive = stateUpdate == ActivityState.active
            }
        }
    }
}

@available(iOS 16.2, *)
struct LiveActivitySection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LiveActivitySection(stopLiveActivity: {}, startLiveActivity: {})
        }
    }
}
