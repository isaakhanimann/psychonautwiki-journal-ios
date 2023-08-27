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
    @Published var isActivityActive = false
    private var activityStateTask: Task<Void, Never>?

    init() {
        if let firstActivity = Activity<TimelineWidgetAttributes>.activities.first {
            self.isActivityActive = firstActivity.activityState == .active
            self.activityStateTask = Task { [weak self] in
                for await activityState in firstActivity.activityStateUpdates {
                    self?.isActivityActive = activityState == .active
                }
            }
        }
    }

    deinit {
        activityStateTask?.cancel()
    }

    func startOrUpdateActivity(
        everythingForEachLine: [EverythingForOneLine],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote]
    ) async {
        if authorizationInfo.areActivitiesEnabled {
            if let firstActivity = Activity<TimelineWidgetAttributes>.activities.first, firstActivity.activityState == .active {
                await updateActivity(
                    activity: firstActivity,
                    everythingForEachLine: everythingForEachLine,
                    everythingForEachRating: everythingForEachRating,
                    everythingForEachTimedNote: everythingForEachTimedNote)
            } else {
                await stopActivity(
                    everythingForEachLine: everythingForEachLine,
                    everythingForEachRating: everythingForEachRating,
                    everythingForEachTimedNote: everythingForEachTimedNote)
                startActivity(
                    everythingForEachLine: everythingForEachLine,
                    everythingForEachRating: everythingForEachRating,
                    everythingForEachTimedNote: everythingForEachTimedNote)
            }
        }
    }

    private func startActivity(
        everythingForEachLine: [EverythingForOneLine],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote]
    ) {
        let attributes = TimelineWidgetAttributes(name: "Passed from app")
        let state = TimelineWidgetAttributes.ContentState(
            everythingForEachLine: everythingForEachLine,
            everythingForEachRating: everythingForEachRating,
            everythingForEachTimedNote: everythingForEachTimedNote
        )
        let content = ActivityContent(state: state, staleDate: nil)
        do {
            let newActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            self.activityStateTask = Task { [weak self] in
                for await activityState in newActivity.activityStateUpdates {
                    self?.isActivityActive = activityState == .active
                }
            }
        } catch {
            print("Failed to start activity: \(error.localizedDescription)")
        }
    }

    private func updateActivity(
        activity: Activity<TimelineWidgetAttributes>,
        everythingForEachLine: [EverythingForOneLine],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote]
    ) async {
        let state = TimelineWidgetAttributes.ContentState(
            everythingForEachLine: everythingForEachLine,
            everythingForEachRating: everythingForEachRating,
            everythingForEachTimedNote: everythingForEachTimedNote)
        let updatedContent = ActivityContent(state: state, staleDate: nil)
        await activity.update(updatedContent)
    }

    func stopActivity(
        everythingForEachLine: [EverythingForOneLine],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote]
    ) async {
        if authorizationInfo.areActivitiesEnabled {
            let state = TimelineWidgetAttributes.ContentState(
                everythingForEachLine: everythingForEachLine,
                everythingForEachRating: everythingForEachRating,
                everythingForEachTimedNote: everythingForEachTimedNote)
            let finalContent = ActivityContent(state: state, staleDate: nil)
            for activity in Activity<TimelineWidgetAttributes>.activities {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
        }
    }
}
