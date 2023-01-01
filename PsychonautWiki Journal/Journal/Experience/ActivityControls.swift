//
//  ActivityControls.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 01.01.23.
//

import SwiftUI
import ActivityKit

@available(iOS 16.1, *)
struct ActivityControls: View {

    @State private var activity: Activity<TimelineWidgetAttributes>? = nil

    var body: some View {
        VStack(spacing: 16) {
            Button("Start Activity", action: startActivity)
            Button("Stop Activity", action: stopActivity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private func startActivity() {
        let attributes = TimelineWidgetAttributes(name: "Passed from app")
        let state = TimelineWidgetAttributes.ContentState(value: 19)
        activity = try? Activity<TimelineWidgetAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
    }


    private func stopActivity() {
        let state = TimelineWidgetAttributes.ContentState(value: 21)
        Task {
            await activity?.end(using: state, dismissalPolicy: .immediate)
        }
    }

    private func updateActivity() {
        let state = TimelineWidgetAttributes.ContentState(value: 20)
        Task {
            await activity?.update(using: state)
        }
    }
}

@available(iOS 16.1, *)
struct ActivityControls_Previews: PreviewProvider {
    static var previews: some View {
        ActivityControls()
    }
}
