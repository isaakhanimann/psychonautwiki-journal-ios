//
//  DurationScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct DurationScreen: View {
    let durationInfos: [DurationInfo]
    @State private var selectedTime = Date()
    @State private var timelineModel: TimelineModel?

    var body: some View {
        List {
            Section {
                DatePicker(
                    "Start Time",
                    selection: $selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                if let model = timelineModel {
                    EffectTimeline(timelineModel: model)
                }
                ForEach(durationInfos, id: \.route) { info in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.title2)
                                .foregroundColor(info.route.color)
                            Text(info.route.rawValue.localizedCapitalized).font(.headline)
                        }
                        OneRoaDurationRow(duration: info.roaDuration, color: info.route.color)
                    }
                }
            }.onAppear {
                timelineModel = TimelineModel(everythingForEachLine: durationInfos.map({ info in
                    EverythingForOneLine(roaDuration: info.roaDuration, startTime: selectedTime, horizontalWeight: 0.5, verticalWeight: 1, color: info.route.color)
                }))
            }
            .onChange(of: selectedTime) { newValue in
                timelineModel = TimelineModel(everythingForEachLine: durationInfos.map({ info in
                    EverythingForOneLine(roaDuration: info.roaDuration, startTime: selectedTime, horizontalWeight: 0.5, verticalWeight: 1, color: info.route.color)
                }))
            }
        }.navigationTitle("Duration")
    }
}

struct DurationScreen_Previews: PreviewProvider {
    static var previews: some View {
        DurationScreen(durationInfos: SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!.durationInfos)
    }
}

struct EverythingForOneLine {
    let roaDuration: RoaDuration?
    let startTime: Date
    let horizontalWeight: Double
    let verticalWeight: Double
    let color: Color
}
