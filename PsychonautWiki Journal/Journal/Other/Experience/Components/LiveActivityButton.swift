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
import SwiftUI

@available(iOS 16.2, *)
struct LiveActivityButton: View {
    let stopLiveActivity: () -> Void
    let startLiveActivity: () -> Void
    @ObservedObject var activityManager = ActivityManager.shared
    @State private var areActivitiesEnabled = false

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
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Button {
                        Task {
                            await UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Enable Live Activities", systemImage: "gearshape")
                    }
                }
            }
        }
        .task {
            let authorizationInfo = ActivityManager.shared.authorizationInfo
            self.areActivitiesEnabled = authorizationInfo.areActivitiesEnabled
            for await isEnabled in authorizationInfo.activityEnablementUpdates {
                self.areActivitiesEnabled = isEnabled
            }
        }
    }
}

@available(iOS 16.2, *)
#Preview {
    List {
        LiveActivityButton(stopLiveActivity: {}, startLiveActivity: {})
    }
}
