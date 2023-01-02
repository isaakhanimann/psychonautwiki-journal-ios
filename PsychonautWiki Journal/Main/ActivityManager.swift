//
//  ActivityManager.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 02.01.23.
//

import Foundation
import ActivityKit

@available(iOS 16.2, *)
@MainActor
class ActivityManager: ObservableObject {

    static let shared = ActivityManager()
    let authorizationInfo = ActivityAuthorizationInfo()
    @Published var activity: Activity<TimelineWidgetAttributes>? = nil
    @Published var isActivityActive = false

    init() {
        if let first = Activity<TimelineWidgetAttributes>.activities.first {
            self.activity = first
            Task {
                for await activityState in first.activityStateUpdates {
                    self.isActivityActive = activityState == .active
                }
            }
        }

    }

    func startOrUpdateActivity(everythingForEachLine: [EverythingForOneLine]) {
        if authorizationInfo.areActivitiesEnabled {
            if let activity, isActivityActive {
                updateActivity(activity: activity, everythingForEachLine: everythingForEachLine)
            } else {
                startActivity(everythingForEachLine: everythingForEachLine)
            }
        }
    }

    private func startActivity(everythingForEachLine: [EverythingForOneLine]) {
        let attributes = TimelineWidgetAttributes(name: "Passed from app")
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
        let content = ActivityContent(state: state, staleDate: nil)
        do {
            let newActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            self.activity = newActivity
            Task {
                for await activityState in newActivity.activityStateUpdates {
                    self.isActivityActive = activityState == .active
                }
            }
        } catch {
            print("Failed to start activity: \(error.localizedDescription)")
        }
    }

    private func updateActivity(activity: Activity<TimelineWidgetAttributes>, everythingForEachLine: [EverythingForOneLine]) {
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
        let updatedContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(updatedContent)
        }
    }

    func stopActivity(everythingForEachLine: [EverythingForOneLine]) {
        if authorizationInfo.areActivitiesEnabled {
            let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
            let finalContent = ActivityContent(state: state, staleDate: nil)
            Task {
                await activity?.end(finalContent, dismissalPolicy: .immediate)
            }
        }
    }
}
