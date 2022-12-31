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
    @State private var hiddenRoutes: [AdministrationRoute] = []

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
                    let isRouteHidden = hiddenRoutes.contains(info.route)
                    HStack(alignment: .center) {
                        if isRouteHidden {
                            Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                        }
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
                    .swipeActions(edge: .leading) {
                        Button {
                            toggle(route: info.route)
                        } label: {
                            if isRouteHidden {
                                Label("Show", systemImage: "eye.fill").labelStyle(.iconOnly)
                            } else {
                                Label("Hide", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                            }
                        }
                    }
                }
            }
        }.onAppear {
            updateModel()
        }
        .onChange(of: selectedTime) { _ in
            updateModel()
        }
        .onChange(of: hiddenRoutes) { _ in
            updateModel()
        }
        .navigationTitle("Duration")
    }

    private func updateModel() {
        let durationsToShow = durationInfos.filter { info in
            !hiddenRoutes.contains(info.route)
        }
        timelineModel = TimelineModel(everythingForEachLine: durationsToShow.map({ info in
            EverythingForOneLine(roaDuration: info.roaDuration, startTime: selectedTime, horizontalWeight: 0.5, verticalWeight: 1, color: info.route.color)
        }))
    }

    private func toggle(route: AdministrationRoute) {
        if hiddenRoutes.contains(route) {
            hiddenRoutes.removeAll { sel in
                sel == route
            }
        } else {
            hiddenRoutes.append(route)
        }
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
