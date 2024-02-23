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

// swiftlint:disable type_body_length
struct ExperienceScreen: View {
    @ObservedObject var experience: Experience

    @State private var isShowingAddIngestionFullScreen = false
    @AppStorage(PersistenceController.timeDisplayStyleKey) private var timeDisplayStyleText: String = SaveableTimeDisplayStyle.regular.rawValue

    private var saveableTimeDisplayStyle: Binding<SaveableTimeDisplayStyle> {
        Binding(
            get: {
                SaveableTimeDisplayStyle(rawValue: timeDisplayStyleText) ?? .regular
            },
            set: { newValue in timeDisplayStyleText = newValue.rawValue }
        )
    }

    var timeDisplayStyle: TimeDisplayStyle {
        switch saveableTimeDisplayStyle.wrappedValue {
        case .regular:
            return .regular
        case .relativeToNow:
            return .relativeToNow
        case .relativeToStart:
            return .relativeToStart
        case .auto:
            if experience.isCurrent {
                return .relativeToNow
            } else {
                return .relativeToStart
            }
        }
    }

    @State private var isShowingDeleteConfirmation = false
    @State private var sheetToShow: SheetOption?
    @State private var hiddenIngestions: [ObjectIdentifier] = []
    @State private var hiddenRatings: [ObjectIdentifier] = []
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @AppStorage(PersistenceController.isHidingDosageDotsKey) var isHidingDosageDots: Bool = false
    @AppStorage(PersistenceController.isHidingToleranceChartInExperienceKey) var isHidingToleranceChartInExperience: Bool = false
    @AppStorage(PersistenceController.isHidingSubstanceInfoInExperienceKey) var isHidingSubstanceInfoInExperience: Bool = false
    @AppStorage(PersistenceController.areRedosesDrawnIndividuallyKey) var areRedosesDrawnIndividually: Bool = false
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
            if let lastTime = experience.myIngestionsSorted.last?.time, lastTime > Date.now.addingTimeInterval(-12 * 60 * 60) && ActivityManager.shared.isActivityActive {
                startOrUpdateLiveActivity()
            }
        }
    }

    @available(iOS 16.2, *)
    func startOrUpdateLiveActivity() {
        Task {
            await ActivityManager.shared.startOrUpdateActivity(
                substanceGroups: getSubstanceIngestionGroups(ingestions: experience.myIngestionsSorted.filter { !hiddenIngestions.contains($0.id) }),
                everythingForEachRating: experience.ratingsWithTimeSorted
                    .filter { !hiddenRatings.contains($0.id) }
                    .map { shulgin in
                        EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                    },
                everythingForEachTimedNote: experience.timedNotesForTimeline,
                areRedosesDrawnIndividually: areRedosesDrawnIndividually
            )
        }
    }

    @available(iOS 16.2, *)
    func stopLiveActivity() {
        Task {
            await ActivityManager.shared.stopActivity(
                substanceGroups: getSubstanceIngestionGroups(ingestions: experience.myIngestionsSorted.filter { !hiddenIngestions.contains($0.id) }),
                everythingForEachRating: experience.ratingsWithTimeSorted
                    .filter { !hiddenRatings.contains($0.id) }
                    .map { shulgin in
                        EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                    },
                everythingForEachTimedNote: experience.timedNotesForTimeline,
                areRedosesDrawnIndividually: areRedosesDrawnIndividually
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
                            timelineModel: experience.getMyTimeLineModel(
                                hiddenIngestions: hiddenIngestions,
                                hiddenRatings: hiddenRatings,
                                areRedosesDrawnIndividually: areRedosesDrawnIndividually
                            ),
                            hiddenIngestions: hiddenIngestions,
                            ingestionsSorted: experience.myIngestionsSorted,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots,
                            showIngestion: { showIngestion(id: $0) },
                            hideIngestion: { hideIngestion(id: $0) },
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
                        Text(experience.sortDateUnwrapped, format: Date.FormatStyle().day().month().year().weekday(.abbreviated))
                    }
                    if !experience.myCumulativeDoses.isEmpty && isEyeOpen {
                        Section("My cumulative dose") {
                            ForEach(experience.myCumulativeDoses) { cumulative in
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
                                    firstIngestionTime: experience.ingestionsSorted.first?.time
                                )
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
                if !experience.chartData.toleranceWindows.isEmpty && !isHidingToleranceChartInExperience && isEyeOpen {
                    Section {
                        NavigationLink {
                            ToleranceTextsScreen(substances: experience.chartData.substancesInChart)
                        } label: {
                            ToleranceChart(
                                toleranceWindows: experience.chartData.toleranceWindows,
                                numberOfRows: experience.chartData.numberOfSubstancesInToleranceChart,
                                timeOption: .onlyIfCurrentTimeInChart,
                                experienceStartDate: experience.sortDateUnwrapped.getDateWithoutTime()
                            )
                        }
                    } header: {
                        Text("Tolerance")
                    } footer: {
                        if !experience.chartData.namesOfSubstancesWithMissingTolerance.isEmpty {
                            Text("Excluding ") + Text(experience.chartData.namesOfSubstancesWithMissingTolerance, format: .list(type: .and))
                        }
                    }
                }
                ForEach(experience.getConsumers(hiddenIngestions: hiddenIngestions, areRedosesDrawnIndividually: areRedosesDrawnIndividually)) { consumer in
                    Section(consumer.consumerName) {
                        TimelineSection(
                            timelineModel: consumer.timelineModel,
                            hiddenIngestions: hiddenIngestions,
                            ingestionsSorted: consumer.ingestionsSorted,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots,
                            showIngestion: { showIngestion(id: $0) },
                            hideIngestion: { hideIngestion(id: $0) },
                            updateActivityIfActive: {}
                        )
                    }
                }
                if isEyeOpen && !isHidingSubstanceInfoInExperience && !experience.substancesUsed.isEmpty {
                    Section("Info") {
                        ForEach(experience.substancesUsed) { substance in
                            NavigationLink {
                                SubstanceScreen(substance: substance)
                            } label: {
                                Label(substance.name, systemImage: "info.circle")
                            }
                        }
                        if experience.substancesUsed.contains(where: { $0.isHallucinogen }) {
                            NavigationLink {
                                SaferHallucinogenScreen()
                            } label: {
                                Label("Safer Hallucinogens", systemImage: "cross")
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
                            NavigationLink {
                                GoThroughAllInteractionsScreen(substancesToCheck: experience.substancesUsed)
                            } label: {
                                Label("See Interactions", systemImage: "exclamationmark.triangle")
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
                case let .editLocation(experienceLocation):
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
                    saveableTimeDisplayStyle: saveableTimeDisplayStyle,
                    sheetToShow: $sheetToShow,
                    isShowingDeleteConfirmation: $isShowingDeleteConfirmation
                )
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

    private func delete() {
        PersistenceController.shared.viewContext.delete(experience)
        PersistenceController.shared.saveViewContext()
        if #available(iOS 16.2, *) {
            stopLiveActivity()
        }
        dismiss()
    }
}
// swiftlint:enable type_body_length
