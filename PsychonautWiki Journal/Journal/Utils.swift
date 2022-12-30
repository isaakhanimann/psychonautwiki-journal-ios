//
//  Utils.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import SwiftUI

enum TimeRange {
    case last30Days
    case last12Months
}

struct TimeRangePicker: View {
    @Binding var value: TimeRange

    var body: some View {
        Picker("Time Range", selection: $value.animation(.easeInOut)) {
            Text("30 Days").tag(TimeRange.last30Days)
            Text("12 Months").tag(TimeRange.last12Months)
        }
        .pickerStyle(.segmented)
    }
}

