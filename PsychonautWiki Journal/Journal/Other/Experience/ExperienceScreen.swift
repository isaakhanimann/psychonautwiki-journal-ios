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

    @ObservedObject var experience: Experience
    @State private var isShowingAddIngestionFullScreen = false
    @State private var timeDisplayStyle = TimeDisplayStyle.regular
    @State private var isShowingDeleteConfirmation = false
    @State private var sheetToShow: SheetOption? = nil

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @AppStorage(PersistenceController.isHidingDosageDotsKey) var isHidingDosageDots: Bool = false
    @AppStorage(PersistenceController.isHidingToleranceChartInExperienceKey) var isHidingToleranceChartInExperience: Bool = false
    @AppStorage(PersistenceController.isHidingSubstanceInfoInExperienceKey) var isHidingSubstanceInfoInExperience: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = ViewModel()


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
                if !viewModel.ingestionsSorted.isEmpty {
                    Section {
                        TimelineSection(
                            timelineModel: viewModel.timelineModel,
                            hiddenIngestions: viewModel.hiddenIngestions,
                            ingestionsSorted: viewModel.ingestionsSorted,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots,
                            showIngestion: {viewModel.showIngestion(id: $0)},
                            hideIngestion: {viewModel.hideIngestion(id: $0)}
                        )
                        if #available(iOS 16.2, *) {
                            if experience.isCurrent {
                                LiveActivityButton(
                                    stopLiveActivity: {
                                        viewModel.stopLiveActivity()
                                    },
                                    startLiveActivity: {
                                        viewModel.startOrUpdateLiveActivity()
                                    }
                                )
                            }
                        }
                    } header: {
                        HStack {
                            let firstDate = experience.ingestionsSorted.first?.time ?? experience.sortDateUnwrapped
                            Text(firstDate, format: Date.FormatStyle().day().month().year().weekday(.abbreviated))
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
                    if !viewModel.cumulativeDoses.isEmpty && isEyeOpen {
                        Section("Cumulative Dose") {
                            ForEach(viewModel.cumulativeDoses) { cumulative in
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
                            }

                        }
                    }
                }
                if isEyeOpen && !experience.ratingsUnwrapped.isEmpty {
                    ShulginRatingSection(
                        experience: experience,
                        viewModel: viewModel,
                        timeDisplayStyle: timeDisplayStyle,
                        firstIngestionTime: experience.ingestionsSorted.first?.timeUnwrapped
                    )
                }
                if #available(iOS 16.0, *) {
                    if !viewModel.toleranceWindows.isEmpty && !isHidingToleranceChartInExperience && isEyeOpen {
                        Section {
                            ToleranceChart(
                                toleranceWindows: viewModel.toleranceWindows,
                                numberOfRows: viewModel.numberOfSubstancesInToleranceChart,
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
                                if !viewModel.namesOfSubstancesWithMissingTolerance.isEmpty {
                                    Text("Excluding ") + Text(viewModel.namesOfSubstancesWithMissingTolerance, format: .list(type: .and))
                                }
                                Spacer()
                                if !viewModel.substancesInChart.isEmpty {
                                    NavigationLink {
                                        ToleranceTextsScreen(substances: viewModel.substancesInChart)
                                    } label: {
                                        Label("More", systemImage: "doc.plaintext")
                                            .labelStyle(.iconOnly)
                                    }
                                }
                            }
                        }
                    }
                }
                ForEach(viewModel.consumers) { consumer in
                    Section(consumer.consumerName) {
                        TimelineSection(
                            timelineModel: consumer.timelineModel,
                            hiddenIngestions: viewModel.hiddenIngestions,
                            ingestionsSorted: consumer.ingestionsSorted,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots,
                            showIngestion: {viewModel.showIngestion(id: $0)},
                            hideIngestion: {viewModel.hideIngestion(id: $0)}
                        )
                    }
                }
                if isEyeOpen && !isHidingSubstanceInfoInExperience && !viewModel.substancesUsed.isEmpty{
                    Section("Info") {
                        ForEach(viewModel.substancesUsed) { substance in
                            NavigationLink(substance.name) {
                                SubstanceScreen(substance: substance)
                            }
                        }
                        ForEach(viewModel.interactions) { interaction in
                            NavigationLink {
                                GoThroughAllInteractionsScreen(substancesToCheck: viewModel.substancesUsed)
                            } label: {
                                InteractionPairRow(
                                    aName: interaction.aName,
                                    bName: interaction.bName,
                                    interactionType: interaction.interactionType
                                )
                            }
                        }
                        if viewModel.interactions.isEmpty {
                            NavigationLink("See Interactions") {
                                GoThroughAllInteractionsScreen(substancesToCheck: viewModel.substancesUsed)
                            }
                        }
                        if viewModel.substancesUsed.contains(where: {$0.isHallucinogen}) {
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
            .task {
                viewModel.experience = experience
                viewModel.reloadScreen(experience: experience)
            }
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
            viewModel.stopLiveActivity()
        }
        dismiss()
    }
}
