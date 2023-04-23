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

import Foundation
import ActivityKit

@available(iOS 16.2, *)
@MainActor
class ActivityManager: ObservableObject {

    static let shared = ActivityManager()
    let authorizationInfo = ActivityAuthorizationInfo()
    @Published var activity: Activity<TimelineWidgetAttributes>? = nil
    @Published var isActivityActive = false
    private var activityStateTask: Task<Void, Never>?

    init() {
        if let first = Activity<TimelineWidgetAttributes>.activities.first {
            self.isActivityActive = first.activityState == .active
            self.activity = first
            self.activityStateTask = Task {
                for await activityState in first.activityStateUpdates {
                    self.isActivityActive = activityState == .active
                }
            }
        }
    }

    deinit {
        activityStateTask?.cancel()
    }

    func startOrUpdateActivity(everythingForEachLine: [EverythingForOneLine], everythingForEachRating: [EverythingForOneRating]) {
        if authorizationInfo.areActivitiesEnabled {
            if let activity, isActivityActive {
                updateActivity(activity: activity, everythingForEachLine: everythingForEachLine, everythingForEachRating: everythingForEachRating)
            } else {
                startActivity(everythingForEachLine: everythingForEachLine, everythingForEachRating: everythingForEachRating)
            }
        }
    }

    private func startActivity(everythingForEachLine: [EverythingForOneLine], everythingForEachRating: [EverythingForOneRating]) {
        let attributes = TimelineWidgetAttributes(name: "Passed from app")
        let state = TimelineWidgetAttributes.ContentState(
            everythingForEachLine: everythingForEachLine,
            everythingForEachRating: everythingForEachRating
        )
        let content = ActivityContent(state: state, staleDate: nil)
        do {
            let newActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            self.activity = newActivity
            self.activityStateTask = Task {
                for await activityState in newActivity.activityStateUpdates {
                    self.isActivityActive = activityState == .active
                }
            }
        } catch {
            print("Failed to start activity: \(error.localizedDescription)")
        }
    }

    private func updateActivity(activity: Activity<TimelineWidgetAttributes>, everythingForEachLine: [EverythingForOneLine], everythingForEachRating: [EverythingForOneRating]) {
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine, everythingForEachRating: everythingForEachRating)
        let updatedContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(updatedContent)
        }
    }

    func stopActivity(everythingForEachLine: [EverythingForOneLine], everythingForEachRating: [EverythingForOneRating]) {
        if authorizationInfo.areActivitiesEnabled {
            let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine, everythingForEachRating: everythingForEachRating)
            let finalContent = ActivityContent(state: state, staleDate: nil)
            Task {
                for activity in Activity<TimelineWidgetAttributes>.activities {
                    await activity.end(finalContent, dismissalPolicy: .immediate)
                }
            }
        }
    }
}
