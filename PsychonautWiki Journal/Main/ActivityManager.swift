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

    private var activity: Activity<TimelineWidgetAttributes>? = nil
    private let authorizationInfo = ActivityAuthorizationInfo()


    func startActivity(everythingForEachLine: [EverythingForOneLine]) {
        if authorizationInfo.areActivitiesEnabled {
            let attributes = TimelineWidgetAttributes(name: "Passed from app")
            let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
            let content = ActivityContent(state: state, staleDate: nil)
            activity = try? Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        }
    }

    func updateActivity(everythingForEachLine: [EverythingForOneLine]) {
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
        let updatedContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity?.update(updatedContent)
        }
    }

    func stopActivity(everythingForEachLine: [EverythingForOneLine]) {
        let state = TimelineWidgetAttributes.ContentState(everythingForEachLine: everythingForEachLine)
        let finalContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity?.end(finalContent, dismissalPolicy: .default)
        }
    }


}
