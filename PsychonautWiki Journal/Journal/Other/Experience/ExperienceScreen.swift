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

struct ExperienceScreen: View {

    @ObservedObject var experience: Experience

    @State private var isShowingAddIngestionFullScreen = false
    @State private var timeDisplayStyle = TimeDisplayStyle.regular
    @State private var isShowingDeleteConfirmation = false
    @State private var sheetToShow: SheetOption? = nil
    @State private var hiddenIngestions: [ObjectIdentifier] = []
    @State private var hiddenRatings: [ObjectIdentifier] = []
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @AppStorage(PersistenceController.isHidingDosageDotsKey) var isHidingDosageDots: Bool = false
    @AppStorage(PersistenceController.isHidingToleranceChartInExperienceKey) var isHidingToleranceChartInExperience: Bool = false
    @AppStorage(PersistenceController.isHidingSubstanceInfoInExperienceKey) var isHidingSubstanceInfoInExperience: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager

    enum SheetOption: Identifiable, Hashable {
        case editTitle
        case editNotes
        case editLocation(experienceLocation: ExperienceLocation)
        case addLocation
        case addRating
        case addTimedNote

        var id: Self {
            return self
        }
    }

    private func showIngestion(id: ObjectIdentifier) {
        hiddenIngestions.removeAll { hiddenID in
            hiddenID == id
        }
        updateActivityIfActive()
    }

    private func hideIngestion(id: ObjectIdentifier) {
        hiddenIngestions.append(id)
        updateActivityIfActive()
    }

    private func showRating(id: ObjectIdentifier) {
        hiddenRatings.removeAll { hiddenID in
            hiddenID == id
        }
        updateActivityIfActive()
    }

    private func hideRating(id: ObjectIdentifier) {
        hiddenRatings.append(id)
        updateActivityIfActive()
    }

    func updateActivityIfActive() {
        if #available(iOS 16.2, *) {
            if let lastTime = experience.myIngestionsSorted.last?.time, lastTime > Date.now.addingTimeInterval(-12*60*60) && ActivityManager.shared.isActivityActive {
                startOrUpdateLiveActivity()
            }
        }
    }

    @available(iOS 16.2, *)
    func startOrUpdateLiveActivity() {
        Task {
            await ActivityManager.shared.startOrUpdateActivity(
                everythingForEachLine: getEverythingForEachLine(from: experience.myIngestionsSorted.filter { !hiddenIngestions.contains($0.id) }),
                everythingForEachRating: experience.ratingsWithTimeSorted
                    .filter {!hiddenRatings.contains($0.id)}
                    .map({ shulgin in
                        EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                    }),
                everythingForEachTimedNote: experience.timedNotesForTimeline
            )
        }
    }

    @available(iOS 16.2, *)
    func stopLiveActivity() {
        Task {
            await ActivityManager.shared.stopActivity(
                everythingForEachLine: getEverythingForEachLine(from: experience.myIngestionsSorted.filter { !hiddenIngestions.contains($0.id) }),
                everythingForEachRating: experience.ratingsWithTimeSorted
                    .filter {!hiddenRatings.contains($0.id)}
                    .map({ shulgin in
                        EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                    }),
                everythingForEachTimedNote: experience.timedNotesForTimeline
            )
        }
    }


    var body: some View {
        FabPosition {
            if experience.isCurrent {
                Button {
                    isShowingAddIngestionFullScreen.toggle()
                } label: {
                    Label("New Ingestion", systemImage: "plus").labelStyle(FabLabelStyle())
                }
            }
        } screen: {
            List {
                if !experience.myIngestionsSorted.isEmpty {
                    Section {
                        TimelineSection(
                            timelineModel: experience.getMyTimeLineModel(hiddenIngestions: hiddenIngestions, hiddenRatings: hiddenRatings),
                            hiddenIngestions: hiddenIngestions,
                            ingestionsSorted: experience.myIngestionsSorted,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots,
                            showIngestion: {showIngestion(id: $0)},
                            hideIngestion: {hideIngestion(id: $0)},
                            updateActivityIfActive: updateActivityIfActive
                        )
                        if #available(iOS 16.2, *) {
                            if experience.isCurrent {
                                LiveActivityButton(
                                    stopLiveActivity: {
                                        stopLiveActivity()
                                    },
                                    startLiveActivity: {
                                        startOrUpdateLiveActivity()
                                    }
                                )
                            }
                        }
                    } header: {
                        HStack {
                            Text(experience.sortDateUnwrapped, format: Date.FormatStyle().day().month().year().weekday(.abbreviated))
                            if isEyeOpen {
                                Spacer()
                                NavigationLink {
                                    ExplainExperienceSectionScreen()
                                } label: {
                                    limitationsLabel
                                }
                            }
                        }
                    }
                    if !experience.cumulativeDoses.isEmpty && isEyeOpen {
                        Section("Cumulative Dose") {
                            ForEach(experience.cumulativeDoses) { cumulative in
                                if let substance = SubstanceRepo.shared.getSubstance(name: cumulative.substanceName) {
                                    NavigationLink {
                                        DosesScreen(substance: substance)
                                    } label: {
                                        CumulativeDoseRow(
                                            substanceName: cumulative.substanceName,
                                            substanceColor: cumulative.substanceColor,
                                            cumulativeRoutes: cumulative.cumulativeRoutes,
                                            isHidingDosageDots: isHidingDosageDots,
                                            isEyeOpen: isEyeOpen
                                        )
                                    }
                                } else {
                                    CumulativeDoseRow(
                                        substanceName: cumulative.substanceName,
                                        substanceColor: cumulative.substanceColor,
                                        cumulativeRoutes: cumulative.cumulativeRoutes,
                                        isHidingDosageDots: isHidingDosageDots,
                                        isEyeOpen: isEyeOpen
                                    )
                                }
                            }
                        }

                    }
                }
                let notes = experience.textUnwrapped
                if !notes.isEmpty {
                    Section("Notes") {
                        Text(notes)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                sheetToShow = .editNotes
                            }
                    }
                }
                let timedNotesSorted = experience.timedNotesSorted
                if !timedNotesSorted.isEmpty {
                    Section("Timed Notes") {
                        ForEach(timedNotesSorted) { timedNote in
                            NavigationLink {
                                EditTimedNoteScreen(timedNote: timedNote, experience: experience)
                            } label: {
                                TimedNoteRow(
                                    timedNote: timedNote,
                                    timeDisplayStyle: timeDisplayStyle,
                                    firstIngestionTime: experience.ingestionsSorted.first?.time)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        PersistenceController.shared.viewContext.delete(timedNote)
                                        PersistenceController.shared.saveViewContext()
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }

                        }
                    }
                }
                if isEyeOpen && !experience.ratingsUnwrapped.isEmpty {
                    ShulginRatingSection(
                        experience: experience,
                        hiddenRatings: hiddenRatings,
                        showRating: showRating,
                        hideRating: hideRating,
                        timeDisplayStyle: timeDisplayStyle,
                        firstIngestionTime: experience.ingestionsSorted.first?.timeUnwrapped
                    )
                }
                if #available(iOS 16.0, *) {
                    if !experience.chartData.toleranceWindows.isEmpty && !isHidingToleranceChartInExperience && isEyeOpen {
                        Section {
                            ToleranceChart(
                                toleranceWindows: experience.chartData.toleranceWindows,
                                numberOfRows: experience.chartData.numberOfSubstancesInToleranceChart,
                                timeOption: .onlyIfCurrentTimeInChart,
                                experienceStartDate: experience.sortDateUnwrapped.getDateWithoutTime()
                            )
                        } header: {
                            HStack {
                                Text("Tolerance")
                                Spacer()
                                NavigationLink {
                                    ToleranceChartExplanationScreen()
                                } label: {
                                    limitationsLabel
                                }
                            }
                        } footer: {
                            HStack {
                                if !experience.chartData.namesOfSubstancesWithMissingTolerance.isEmpty {
                                    Text("Excluding ") + Text(experience.chartData.namesOfSubstancesWithMissingTolerance, format: .list(type: .and))
                                }
                                Spacer()
                                if !experience.chartData.substancesInChart.isEmpty {
                                    NavigationLink {
                                        ToleranceTextsScreen(substances: experience.chartData.substancesInChart)
                                    } label: {
                                        Label("More", systemImage: "doc.plaintext")
                                            .labelStyle(.iconOnly)
                                    }
                                }
                            }
                        }
                    }
                }
                ForEach(experience.getConsumers(hiddenIngestions: hiddenIngestions)) { consumer in
                    Section(consumer.consumerName) {
                        TimelineSection(
                            timelineModel: consumer.timelineModel,
                            hiddenIngestions: hiddenIngestions,
                            ingestionsSorted: consumer.ingestionsSorted,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots,
                            showIngestion: {showIngestion(id: $0)},
                            hideIngestion: {hideIngestion(id: $0)},
                            updateActivityIfActive: {}
                        )
                    }
                }
                if isEyeOpen && !isHidingSubstanceInfoInExperience && !experience.substancesUsed.isEmpty{
                    Section("Info") {
                        ForEach(experience.substancesUsed) { substance in
                            NavigationLink(substance.name) {
                                SubstanceScreen(substance: substance)
                            }
                        }
                        ForEach(experience.interactions) { interaction in
                            NavigationLink {
                                GoThroughAllInteractionsScreen(substancesToCheck: experience.substancesUsed)
                            } label: {
                                InteractionPairRow(
                                    aName: interaction.aName,
                                    bName: interaction.bName,
                                    interactionType: interaction.interactionType
                                )
                            }
                        }
                        if experience.interactions.isEmpty {
                            NavigationLink("See Interactions") {
                                GoThroughAllInteractionsScreen(substancesToCheck: experience.substancesUsed)
                            }
                        }
                        if experience.substancesUsed.contains(where: {$0.isHallucinogen}) {
                            NavigationLink {
                                SaferHallucinogenScreen()
                            } label: {
                                Label("Safer Hallucinogens", systemImage: "cross")
                            }
                        }
                    }
                }
                if let location = experience.location {
                    Section {
                        EditLocationLinkAndMap(experienceLocation: location)
                    } header: {
                        HStack {
                            Text("Location")
                            Spacer()
                            Button {
                                sheetToShow = .editLocation(experienceLocation: location)
                            } label: {
                                Label("Edit Location", systemImage: "pencil")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                }
            }
            .dismissWhenTabTapped()
            .sheet(item: $sheetToShow, content: { sheet in
                switch sheet {
                case .addLocation:
                    AddLocationScreen(locationManager: locationManager, experience: experience)
                case .editLocation(let experienceLocation):
                    EditLocationScreen(experienceLocation: experienceLocation, locationManager: locationManager)
                case .editNotes:
                    EditNotesScreen(experience: experience)
                case .editTitle:
                    EditTitleScreen(experience: experience)
                case .addRating:
                    AddRatingScreen(experience: experience, canDefineOverall: experience.overallRating == nil)
                case .addTimedNote:
                    AddTimedNoteScreen(experience: experience)
                }
            })
        }
        .navigationTitle(experience.titleUnwrapped)
        .fullScreenCover(isPresented: $isShowingAddIngestionFullScreen, content: {
            ChooseSubstanceScreen()
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ExperienceToolbarContent(
                    experience: experience,
                    timeDisplayStyle: $timeDisplayStyle,
                    sheetToShow: $sheetToShow,
                    isShowingDeleteConfirmation: $isShowingDeleteConfirmation)
            }
        }
        .confirmationDialog(
            "Delete Experience?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Delete", role: .destructive) {
                    delete()
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("This will also delete all of its ingestions.")
            }
        )

    }

    private var limitationsLabel: some View {
        Label("Limitations", systemImage: "info.circle")
            .labelStyle(.titleOnly)
            .font(.callout)
    }

    private func delete() {
        PersistenceController.shared.viewContext.delete(experience)
        PersistenceController.shared.saveViewContext()
        if #available(iOS 16.2, *) {
            stopLiveActivity()
        }
        dismiss()
    }
}
