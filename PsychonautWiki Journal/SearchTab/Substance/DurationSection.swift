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

    var body: some View {
        Section("Duration") {
            DatePicker(
                "Start Time",
                selection: $selectedTime,
                displayedComponents: [.hourAndMinute]
            )
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                context.stroke(path, with: .foreground, lineWidth: 6)
            }
            .frame(height: 200)
            ForEach(durationInfos, id: \.route) { info in
                VStack(alignment: .leading) {
                    Text(info.route).font(.headline)
                    OneRoaDurationRow(duration: info.roaDuration)
                }
            }
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
