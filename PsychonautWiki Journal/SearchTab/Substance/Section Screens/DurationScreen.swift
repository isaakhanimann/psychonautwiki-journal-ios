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
    private let lineWidth: Double = 5

    var body: some View {
        List {
            Section {
                DatePicker(
                    "Start Time",
                    selection: $selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                if let model = timelineModel {
                    let halfLineWidth = lineWidth/2
                    VStack(spacing: 0) {
                        Canvas { context, size in
                            let pixelsPerSec = (size.width-halfLineWidth)/model.totalWidth
                            model.ingestionDrawables.forEach({ drawable in
                                let startX = (drawable.distanceFromStart * pixelsPerSec) + halfLineWidth
                                drawable.timelineDrawable.drawTimeLineWithShape(
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
                            let widthInPixels = size.width - halfLineWidth
                            let pixelsPerSec = widthInPixels/model.totalWidth
                            let fullHours = model.axisDrawable.getFullHours(
                                pixelsPerSec: pixelsPerSec,
                                widthInPixels: widthInPixels
                            )
                            fullHours.forEach { fullHour in
                                context.draw(
                                    Text(fullHour.label).font(.caption),
                                    at: CGPoint(x: fullHour.distanceFromStart + halfLineWidth, y: size.height/2),
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
