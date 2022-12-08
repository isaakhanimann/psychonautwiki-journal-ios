//
//  DurationSection.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.12.22.
//

import SwiftUI

struct DurationSection: View {

    let durationInfos: [DurationInfo]
    @State private var selectedTime = Date()
    @State private var timelineModel: TimelineModel?
    private let lineWidth: Double = 6

    var body: some View {
        Section("Duration") {
            DatePicker(
                "Start Time",
                selection: $selectedTime,
                displayedComponents: [.hourAndMinute]
            )
            Canvas { context, size in
                if let model = timelineModel {
                    let pixelsPerSec = size.width/model.totalWidth
                    model.ingestionDrawables.forEach({ drawable in
                        let startX = drawable.distanceFromStart * pixelsPerSec
                        drawable.timelineDrawable?.drawTimeLineWithShape(
                            context: context,
                            height: size.height,
                            startX: startX,
                            pixelsPerSec: pixelsPerSec,
                            color: drawable.color,
                            lineWidth: lineWidth
                        )
                    })
                }
            }
            .frame(height: 200)
            .border(Color.blue)
            ForEach(durationInfos, id: \.route) { info in
                VStack(alignment: .leading) {
                    Text(info.route).font(.headline)
                    OneRoaDurationRow(duration: info.roaDuration)
                }
            }
        }.onAppear {
            timelineModel = TimelineModel(everythingForEachLine: durationInfos.map({ info in
                EverythingForOneLine(roaDuration: info.roaDuration, startTime: selectedTime, horizontalWeight: 0.5, verticalWeight: 1, color: .blue)
            }))
        }
    }
}

struct DurationSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                DurationSection(durationInfos: SubstanceRepo.shared.getSubstance(name: "MDMA")!.durationInfos)
            }
        }
    }
}

struct EverythingForOneLine {
    let roaDuration: RoaDuration?
    let startTime: Date
    let horizontalWeight: Double
    let verticalWeight: Double
    let color: Color
}
