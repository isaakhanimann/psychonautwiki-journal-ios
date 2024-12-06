// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct DurationSection: View {

    let substance: Substance

    @State private var selectedTime = Date()
    @State private var timelineModel: TimelineModel?
    @State private var stomachFullness = StomachFullness.empty
    @State private var hiddenRoutes: [AdministrationRoute] = []

    @AppStorage(PersistenceController.timeDisplayStyleDurationSectionKey) private var timeDisplayStyleDurationSectionText: String = SaveableTimeDisplayStyle.auto.rawValue

    private var saveableTimeDisplayStyle: SaveableTimeDisplayStyle {
        SaveableTimeDisplayStyle(rawValue: timeDisplayStyleDurationSectionText) ?? .auto
    }

    var timeDisplayStyle: TimeDisplayStyle {
        switch saveableTimeDisplayStyle {
        case .regular:
            return .regular
        case .relativeToNow, .auto, .relativeToStart, .between:
            return .relativeToNow
        }
    }

    var body: some View {
        Group {
            if let timelineModel { // have the if let here instead of in the section because the height of the item in the section is fixed when its first rendered
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            DatePicker(
                                "Start Time",
                                selection: $selectedTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            Button("Now") {
                                selectedTime = .now
                            }
                            .buttonStyle(.bordered)
                        }
                        EffectTimeline(
                            timelineModel: timelineModel,
                            timeDisplayStyle: timeDisplayStyle
                        )
                        Text(TimelineDisclaimers.heavyDose).font(.footnote)
                    }
                    listItems
                } header: {
                    HStack {
                        Text("Duration")
                        Spacer()
                        NavigationLink(value: GlobalNavigationDestination.timelineInfo) {
                            Label("Info", systemImage: "info.circle").labelStyle(.iconOnly)
                        }
                    }
                }
            } else {
                Section("Duration") {
                    listItems
                }
            }
        }
        .onAppear {
            updateModel()
        }
        .onChange(of: selectedTime) { _ in
            updateModel()
        }
        .onChange(of: hiddenRoutes) { _ in
            updateModel()
        }
        .onChange(of: stomachFullness) { _ in
            updateModel()
        }

    }

    private var listItems: some View {
        ForEach(substance.durationInfos, id: \.route) { info in
            let isRouteHidden = hiddenRoutes.contains(info.route)
            HStack(alignment: .center, spacing: 8) {
                if isRouteHidden {
                    Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                }
                ColorRectangle(color: info.route.color.swiftUIColor)
                VStack(alignment: .leading) {
                    Text(info.route.rawValue.localizedCapitalized).font(.headline)
                    OneRoaDurationRow(duration: info.roaDuration, color: info.route.color)
                    if info.route == .oral {
                        Spacer().frame(height: 5)
                        VStack(alignment: .leading) {
                            Text("Stomach Fullness Delay").font(.footnote.weight(.medium))
                            Picker("Stomach Fullness", selection: $stomachFullness) {
                                ForEach(StomachFullness.allCases) { option in
                                    Text(option.text)
                                }
                            }.pickerStyle(.segmented)
                            Text("Onset delayed by ~\(stomachFullness.onsetDelayForOralInHours.asRoundedReadableString) hours.").font(.footnote)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: UIColor.systemGray6))
                        )
                        Text(TimelineDisclaimers.capsule).font(.footnote)
                    }
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

    private func updateModel() {
        let durationsToShow = substance.durationInfos.filter { info in
            !hiddenRoutes.contains(info.route)
        }
        let firstAverageCommonDose = substance.doseInfos.compactMap { dose in
            dose.roaDose.averageCommonDose
        }.first ?? 100
        timelineModel = TimelineModel(
            substanceGroups: durationsToShow.map { info in
                SubstanceIngestionGroup(
                    substanceName: substance.name,
                    color: info.route.color,
                    routeMinInfos: [
                        RouteMinInfo(
                            route: info.route,
                            ingestions: [
                                IngestionMinInfo(
                                    dose: substance.doseInfos.first(where: { $0.route == info.route})?.roaDose.getStrengthRelativeToCommonDose(dose: firstAverageCommonDose),
                                    time: selectedTime,
                                    endTime: nil,
                                    onsetDelayInHours: info.route == .oral ? stomachFullness.onsetDelayForOralInHours : 0
                                ),
                            ]
                        ),
                    ]
                )
            },
            everythingForEachRating: [],
            everythingForEachTimedNote: [],
            areRedosesDrawnIndividually: true,
            areSubstanceHeightsIndependent: false
        )
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

#Preview {
    List {
        let substance = SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!
        DurationSection(substance: substance)
    }
}
