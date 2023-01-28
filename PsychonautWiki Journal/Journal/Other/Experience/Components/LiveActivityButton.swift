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

import SwiftUI
import ActivityKit

@available(iOS 16.2, *)
struct LiveActivityButton: View {

    let stopLiveActivity: () -> Void
    let startLiveActivity: () -> Void
    @ObservedObject var activityManager = ActivityManager.shared
    @State private var areActivitiesEnabled = false
    @State private var isActivityActive = false

    var body: some View {
        Group {
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
            } else if UIDevice.current.userInterfaceIdiom == .phone {
                Text("Enable Live Activities in Settings").foregroundColor(.secondary)
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
            LiveActivityButton(stopLiveActivity: {}, startLiveActivity: {})
        }
    }
}
