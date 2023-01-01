//
//  ActivityControls.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 01.01.23.
//

import SwiftUI
import ActivityKit

@available(iOS 16.2, *)
struct ActivityControls: View {

    @State private var activity: Activity<TimelineWidgetAttributes>? = nil
    @State private var areActivitiesEnabled = false

    var body: some View {
        VStack(spacing: 16) {
            if areActivitiesEnabled {
                Text("Activity is Enabled")
            } else {
                Text("Activity is not enabled")
            }
            Button("Start Activity", action: startActivity)
            Button("Stop Activity", action: stopActivity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .task {
            let authorizationInfo = ActivityAuthorizationInfo()
            self.areActivitiesEnabled = authorizationInfo.areActivitiesEnabled
            for await isEnabled in authorizationInfo.activityEnablementUpdates {
                self.areActivitiesEnabled = isEnabled
            }
        }
    }

    private func startActivity() {
        let attributes = TimelineWidgetAttributes(name: "Passed from app")
        let state = TimelineWidgetAttributes.ContentState(value: 19)
        let content = ActivityContent(state: state, staleDate: nil)
        activity = try? Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    private func updateActivity() {
        let state = TimelineWidgetAttributes.ContentState(value: 20)
        let updatedContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity?.update(updatedContent)
        }
    }

    private func stopActivity() {
        let state = TimelineWidgetAttributes.ContentState(value: 21)
        let finalContent = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity?.end(finalContent, dismissalPolicy: .default)
        }
    }

}

@available(iOS 16.2, *)
struct ActivityControls_Previews: PreviewProvider {
    static var previews: some View {
        ActivityControls()
    }
}
