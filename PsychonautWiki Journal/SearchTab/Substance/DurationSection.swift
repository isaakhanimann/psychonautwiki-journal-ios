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
    private let lineWidth: Double = 5

    var body: some View {
        Section("Duration") {
            DatePicker(
                "Start Time",
                selection: $selectedTime,
                displayedComponents: [.hourAndMinute]
            )
            if let model = timelineModel {
                VStack(spacing: 0) {
                    Canvas { context, size in
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
                    .frame(height: 200)
                    Canvas { context, size in
                        let widthInPixels = size.width
                        let pixelsPerSec = widthInPixels/model.totalWidth
                        let fullHours = model.axisDrawable.getFullHours(
                            pixelsPerSec: pixelsPerSec,
                            widthInPixels: widthInPixels
                        )
                        fullHours.forEach { fullHour in
                            context.draw(
                                Text(fullHour.label).font(.caption),
                                at: CGPoint(x: fullHour.distanceFromStart, y: size.height/2),
                                anchor: .center
                            )
                        }
                    }
                }
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
    }
}

struct DurationSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                DurationSection(durationInfos: SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!.durationInfos)
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
