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
    @ObservedObject var activityManager = ActivityManager.shared
    @State private var areActivitiesEnabled = false
    @State private var isActivityActive = false

    var body: some View {
        Section("Live Activities") {
            if areActivitiesEnabled {
                if activityManager.isActivityActive {
                    Button {
                        stopLiveActivity()
                    } label: {
                        Label("Stop Live Activity", systemImage: "stop")
                    }
                } else {
                    Button {
                        startLiveActivity()
                    } label: {
                        Label("Start Live Activity", systemImage: "play")
                    }
                }
            } else {
                Text("Enable in Settings")
            }
        }
        .task {
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
