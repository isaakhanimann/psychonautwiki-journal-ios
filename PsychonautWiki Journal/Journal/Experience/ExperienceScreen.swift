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
    @State private var isShowingAddIngestionSheet = false
    @State private var isTimeRelative = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isEditing = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    VStack(alignment: .leading) {
                        let timelineHeight: Double = 200
                        if let timelineModel = viewModel.timelineModel {
                            EffectTimeline(timelineModel: timelineModel, height: timelineHeight)
                        } else {
                            Canvas {_,_ in }.frame(height: timelineHeight)
                        }
                        TimelineDisclaimers(isShowingOralDisclaimer: experience.sortedIngestionsUnwrapped.contains(where: {$0.administrationRouteUnwrapped == .oral}))
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
                                    roaDose: roaDose,
                                    isTimeRelative: isTimeRelative,
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
                    let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
                    Text(firstDate, style: .date)
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
            Section("Notes") {
                if let notes = experience.textUnwrapped, !notes.isEmpty {
                    Text(notes)
                        .padding(.vertical, 5)
                        .onTapGesture {
                            isEditing.toggle()
                        }
                } else {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            Section("Location") {
                if let location = experience.location {
                    EditLocationLinkAndMap(experienceLocation: location, locationManager: locationManager)
                } else {
                    NavigationLink {
                        ChooseLocationScreen(locationManager: locationManager)
                            .onAppear {
                                locationManager.selectedLocation = nil
                                locationManager.selectedLocationName = ""
                            }
                            .onDisappear {
                                if let selectedLocation = locationManager.selectedLocation {
                                    let newLocation = ExperienceLocation(context: PersistenceController.shared.viewContext)
                                    newLocation.name = selectedLocation.name
                                    newLocation.latitude = selectedLocation.latitude ?? 0
                                    newLocation.longitude = selectedLocation.longitude ?? 0
                                    newLocation.experience = experience
                                }
                                PersistenceController.shared.saveViewContext()
                            }
                    } label: {
                        Label("Add Location", systemImage: "plus")
                    }
                }
            }
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
        }
        .navigationTitle(experience.titleUnwrapped)
        .sheet(isPresented: $isEditing) {
            EditExperienceScreen(experience: experience)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                let isFavorite = experience.isFavorite
                Button {
                    experience.isFavorite = !isFavorite
                    try? PersistenceController.shared.viewContext.save()
                } label: {
                    if isFavorite {
                        Label("Unfavorite", systemImage: "star.fill")
                    } else {
                        Label("Favorite", systemImage: "star")
                    }
                }
                Button {
                    isEditing.toggle()
                } label: {
                    Label("Edit Title/Note", systemImage: "pencil")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if experience.isCurrent {
                    Button {
                        isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                    }
                    .fullScreenCover(isPresented: $isShowingAddIngestionSheet, content: {
                        ChooseSubstanceScreen()
                    })
                }
                if #available(iOS 16, *) {
                    Button {
                        isTimeRelative.toggle()
                    } label: {
                        if isTimeRelative {
                            Label("Show Absolute Time", systemImage: "timer.circle.fill")
                        } else {
                            Label("Show Relative Time", systemImage: "timer.circle")
                        }
                    }
                }
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
        }
        .task {
            viewModel.setupFetchRequestPredicateAndFetch(experience: experience)
        }
    }

    private func delete() {
        PersistenceController.shared.viewContext.delete(experience)
        PersistenceController.shared.saveViewContext()
        viewModel.stopLiveActivity()
        dismiss()
    }
}
