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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        if #available(iOS 16, *) {
            screen.toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    favoriteButton
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if experience.isCurrent {
                        addIngestionButton
                        Spacer()

                    }
                    Menu(content: {
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
                    }, label: {
                        Label("Time", systemImage: "timer")
                    })
                    Spacer()
                    if experience.location == nil {
                        addLocationButton
                        Spacer()
                    }
                    editTitleButton
                    Spacer()
                    deleteExperienceButton
                }
            }
        } else {
            screen.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    editTitleButton
                    if experience.location == nil {
                        addLocationButton
                        Spacer()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    favoriteButton
                    deleteExperienceButton
                    if experience.isCurrent {
                        addIngestionButton
                    }
                }
            }
        }
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
                Label("Favorite", systemImage: "star")
            }
        }
    }

    private var editTitleButton: some View {
        Button {
            sheetToShow = .titleAndNote
        } label: {
            Label("Edit Title/Note", systemImage: "pencil")
        }
    }

    private var addLocationButton: some View {
        Button {
            sheetToShow = .addLocation
        } label: {
            Label("Add Location", systemImage: "mappin")
        }
    }

    private var addIngestionButton: some View {
        Button {
            isShowingAddIngestionFullScreen.toggle()
        } label: {
            Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
        }
        .fullScreenCover(isPresented: $isShowingAddIngestionFullScreen, content: {
            ChooseSubstanceScreen()
        })
    }

    private var deleteExperienceButton: some View {
        Button(role: .destructive) {
            isShowingDeleteConfirmation.toggle()
        } label: {
            Label("Delete Experience", systemImage: "trash")
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

    private var screen: some View {
        List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    let timelineHeight: Double = 200
                    if let timelineModel = viewModel.timelineModel {
                        EffectTimeline(timelineModel: timelineModel, height: timelineHeight)
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
                                    isEyeOpen: isEyeOpen
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
                        Text(firstDate, style: .date)
                        if isEyeOpen {
                            Spacer()
                            NavigationLink {
                                ExplainExperienceSectionScreen()
                            } label: {
                                Label("Info", systemImage: "info.circle").labelStyle(.iconOnly)
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
                                        cumulativeRoutes: cumulative.cumulativeRoutes
                                    )
                                }
                            } else {
                                CumulativeDoseRow(
                                    substanceName: cumulative.substanceName,
                                    substanceColor: cumulative.substanceColor,
                                    cumulativeRoutes: cumulative.cumulativeRoutes
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
                            sheetToShow = .titleAndNote
                        }
                }
            }
            ShulginRatingSection(experience: experience)
            if isEyeOpen {
                if !viewModel.substancesUsed.isEmpty {
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
                            Label("Edit", systemImage: "pencil").labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .navigationTitle(experience.titleUnwrapped)
        .sheet(item: $sheetToShow, content: { sheet in
            switch sheet {
            case .addLocation:
                AddLocationScreen(locationManager: locationManager, experience: experience)
            case .editLocation(let experienceLocation):
                EditLocationScreen(experienceLocation: experienceLocation, locationManager: locationManager)
            case .titleAndNote:
                EditExperienceScreen(experience: experience)
            }
        })
        .task {
            viewModel.reloadScreen(experience: experience)
        }
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
