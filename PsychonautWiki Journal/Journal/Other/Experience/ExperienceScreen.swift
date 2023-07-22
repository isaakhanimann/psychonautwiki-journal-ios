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
        case titleAndNote
        case editLocation(experienceLocation: ExperienceLocation)
        case addLocation
        case addRating

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
            Menu {
                Button {
                    isShowingAddIngestionFullScreen.toggle()
                } label: {
                    Label("Add Ingestion", systemImage: "plus")
                }
                if isEyeOpen {
                    Button {
                        sheetToShow = .addRating
                    } label: {
                        Label("Add Rating", systemImage: "bolt.fill")
                    }
                }
                Button {
                    sheetToShow = .titleAndNote
                } label: {
                    Label("Edit Title/Note", systemImage: "pencil")
                }
                if experience.location == nil {
                    Button {
                        sheetToShow = .addLocation
                    } label: {
                        Label("Add Location", systemImage: "mappin")
                    }
                }
                Button(role: .destructive) {
                    isShowingDeleteConfirmation.toggle()
                } label: {
                    Label("Delete Experience", systemImage: "trash")
                }
            } label: {
                Label("More", systemImage: "ellipsis").labelStyle(FabLabelStyle())
            }

        } screen: {
            screen
        }
        .fullScreenCover(isPresented: $isShowingAddIngestionFullScreen, content: {
            ChooseSubstanceScreen()
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                favoriteButton
                Menu {
                    ForEach(TimeDisplayStyle.allCases, id: \.self) { option in
                        Button {
                            withAnimation {
                                timeDisplayStyle = option
                            }
                        } label: {
                            if timeDisplayStyle == option {
                                Label(option.text, systemImage: "checkmark")
                            } else {
                                Text(option.text)
                            }
                        }
                    }
                } label: {
                    Label("Time Display", systemImage: "timer")
                }
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

    private var favoriteButton: some View {
        let isFavorite = experience.isFavorite
        return Button {
            experience.isFavorite = !isFavorite
            try? PersistenceController.shared.viewContext.save()
        } label: {
            if isFavorite {
                Label("Unfavorite", systemImage: "star.fill")
            } else {
                Label("Mark Favorite", systemImage: "star")
            }
        }
    }

    private var screen: some View {
        List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    let timelineHeight: Double = 200
                    if let timelineModel = viewModel.timelineModel {
                        NavigationLink {
                            TimelineScreen(timelineModel: timelineModel)
                        } label: {
                            EffectTimeline(timelineModel: timelineModel, height: timelineHeight)
                        }
                    } else {
                        Canvas {_,_ in }.frame(height: timelineHeight)
                    }
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        let isIngestionHidden = viewModel.hiddenIngestions.contains(ing.id)
                        let route = ing.administrationRouteUnwrapped
                        let substance = ing.substance
                        NavigationLink {
                            EditIngestionScreen(
                                ingestion: ing,
                                substanceName: ing.substanceNameUnwrapped,
                                substance: substance,
                                isEyeOpen: isEyeOpen
                            )
                        } label: {
                            let roaDose = substance?.getDose(for: route)
                            HStack(alignment: .center) {
                                if isIngestionHidden {
                                    Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                                }
                                IngestionRow(
                                    ingestion: ing,
                                    firstIngestionTime: experience.sortedIngestionsUnwrapped.first?.timeUnwrapped,
                                    roaDose: roaDose,
                                    timeDisplayStyle: timeDisplayStyle,
                                    isEyeOpen: isEyeOpen,
                                    isHidingDosageDots: isHidingDosageDots
                                )
                            }
                            .swipeActions(edge: .leading) {
                                if isIngestionHidden {
                                    Button {
                                        viewModel.showIngestion(id: ing.id)
                                    } label: {
                                        Label("Show", systemImage: "eye.fill").labelStyle(.iconOnly)
                                    }
                                } else {
                                    Button {
                                        viewModel.hideIngestion(id: ing.id)
                                    } label: {
                                        Label("Hide", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    PersistenceController.shared.viewContext.delete(ing)
                                    PersistenceController.shared.saveViewContext()
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
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
                        let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
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
                Section {
                    Text(notes)
                        .padding(.vertical, 5)
                } header: {
                    HStack {
                        Text("Notes")
                        Spacer()
                        Button {
                            sheetToShow = .titleAndNote
                        } label: {
                            Label("Edit", systemImage: "pencil").labelStyle(.iconOnly)
                        }
                    }
                }
            }
            if !experience.ratingsUnwrapped.isEmpty {
                ShulginRatingSection(
                    experience: experience,
                    viewModel: viewModel,
                    timeDisplayStyle: timeDisplayStyle,
                    firstIngestionTime: experience.sortedIngestionsUnwrapped.first?.timeUnwrapped
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
                            if !viewModel.namesOfSubstancesInIngestionsButNotChart.isEmpty {
                                MissingToleranceText(substanceNames: viewModel.namesOfSubstancesInIngestionsButNotChart)
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
        .navigationTitle(experience.titleUnwrapped)
        .dismissWhenTabTapped()
        .sheet(item: $sheetToShow, content: { sheet in
            switch sheet {
            case .addLocation:
                AddLocationScreen(locationManager: locationManager, experience: experience)
            case .editLocation(let experienceLocation):
                EditLocationScreen(experienceLocation: experienceLocation, locationManager: locationManager)
            case .titleAndNote:
                EditTitleAndNotesScreen(experience: experience)
            case .addRating:
                AddRatingScreen(experience: experience, canDefineOverall: experience.overallRating == nil)
            }
        })
        .task {
            viewModel.experience = experience
            viewModel.reloadScreen(experience: experience)
        }
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
