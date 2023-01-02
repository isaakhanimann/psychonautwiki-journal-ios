//
//  ActivityManager.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 02.01.23.
//

import Foundation
import ActivityKit

@available(iOS 16.2, *)
class ActivityManager: ObservableObject {

    static let shared = ActivityManager()
    let authorizationInfo = ActivityAuthorizationInfo()

    func startOrUpdateActivity(everythingForEachLine: [EverythingForOneLine]) {
        if authorizationInfo.areActivitiesEnabled {
            if let first = Activity<TimelineWidgetAttributes>.activities.first {
                updateActivity(activity: first, everythingForEachLine: everythingForEachLine)
            } else {
                startNewActivity(everythingForEachLine: everythingForEachLine)
            }
        }
    }

    private func startNewActivity(everythingForEachLine: [EverythingForOneLine]) {
        let attributes = TimelineWidgetAttributes(name: "Passed from app")
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
        let content = ActivityContent(state: state, staleDate: nil)
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Failed to start activity: \(error.localizedDescription)")
        }
    }

    private func updateActivity(activity: Activity<TimelineWidgetAttributes>,everythingForEachLine: [EverythingForOneLine]) {
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
        let updatedContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(updatedContent)
        }
    }

    func stopAllActivities(everythingForEachLine: [EverythingForOneLine]) {
        if authorizationInfo.areActivitiesEnabled {
            let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
            let finalContent = ActivityContent(state: state, staleDate: nil)
            Task {
                for activity in Activity<TimelineWidgetAttributes>.activities {
                    await activity.end(finalContent, dismissalPolicy: .immediate)
                    print("Ending the Live Activity: \(activity.id)")
                }
            }
        }
    }
}
