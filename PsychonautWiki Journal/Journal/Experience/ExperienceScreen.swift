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
    @State private var timelineModel: TimelineModel?
    @State private var cumulativeDoses: [CumulativeDose] = []
    @State private var interactions: [Interaction] = []
    @State private var substancesUsed: [Substance] = []
    @State private var isShowingDeleteAlert = false
    @State private var hiddenIngestions: [ObjectIdentifier] = []
    @State private var isEditing = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    VStack(alignment: .leading) {
                        let timelineHeight: Double = 200
                        if let timelineModel {
                            EffectTimeline(timelineModel: timelineModel, height: timelineHeight)
                        } else {
                            Canvas {_,_ in }.frame(height: timelineHeight)
                        }
                        Text("* Heavy doses can have longer durations.").font(.footnote).maybeCondensed()
                        if experience.sortedIngestionsUnwrapped.contains(where: {$0.administrationRouteUnwrapped == .oral}) {
                            Text("* A full stomach delays the onset of oral doses by 3 hours.").font(.footnote).maybeCondensed()
                        }
                    }
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        let isIngestionHidden = hiddenIngestions.contains(ing.id)
                        let route = ing.administrationRouteUnwrapped
                        let substance = ing.substance
                        NavigationLink {
                            EditIngestionScreen(
                                ingestion: ing,
                                substanceName: ing.substanceNameUnwrapped,
                                substance: substance
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
                                    isTimeRelative: isTimeRelative
                                )
                            }
                            .swipeActions(edge: .leading) {
                                if isIngestionHidden {
                                    Button {
                                        hiddenIngestions.removeAll { id in
                                            id == ing.id
                                        }
                                    } label: {
                                        Label("Show", systemImage: "eye.fill").labelStyle(.iconOnly)
                                    }
                                } else {
                                    Button {
                                        hiddenIngestions.append(ing.id)
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
                } header: {
                    let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
                    Text(firstDate, style: .date)
                }
                if !cumulativeDoses.isEmpty {
                    Section("Cumulative Dose") {
                        ForEach(cumulativeDoses) { cumulative in
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
            if isEyeOpen {
                if !substancesUsed.isEmpty {
                    Section("Substance Info") {
                        ForEach(substancesUsed) { substance in
                            NavigationLink(substance.name) {
                                SubstanceScreen(substance: substance)
                            }
                        }
                        ForEach(interactions) { interaction in
                            NavigationLink {
                                GoThroughAllInteractionsScreen(substancesToCheck: substancesUsed)
                            } label: {
                                InteractionPairRow(
                                    aName: interaction.aName,
                                    bName: interaction.bName,
                                    interactionType: interaction.interactionType
                                )
                            }
                        }
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
            if #available(iOS 16.2, *) {
                if experience.isCurrent {
                    LiveActivitySection(
                        stopLiveActivity: stopLiveActivity,
                        startLiveActivity: startOrUpdateLiveActivity
                    )
                }
            }
        }
        .navigationTitle(experience.titleUnwrapped)
        .sheet(isPresented: $isEditing) {
            EditExperienceScreen(experience: experience)
        }
        .toolbar {
            ToolbarItem {
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
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if experience.isCurrent {
                    Button {
                        isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                    }
                    .sheet(isPresented: $isShowingAddIngestionSheet, content: {
                        ChooseSubstanceScreen()
                    })
                }
                Spacer()
                Menu {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Label("Edit Title/Note", systemImage: "pencil")
                    }
                    Button {
                        isTimeRelative.toggle()
                    } label: {
                        if isTimeRelative {
                            Label("Show Absolute Time", systemImage: "timer.circle.fill")
                        } else {
                            Label("Show Relative Time", systemImage: "timer.circle")
                        }
                    }
                    Button(role: .destructive) {
                        isShowingDeleteAlert.toggle()
                    } label: {
                        Label("Delete Experience", systemImage: "trash")
                    }
                } label: {
                    Label("More", systemImage: isTimeRelative ? "ellipsis.circle.fill" : "ellipsis.circle")                }
                .alert(isPresented: $isShowingDeleteAlert) {
                    Alert(
                        title: Text("Delete Experience?"),
                        message: Text("This will also delete all of its ingestions."),
                        primaryButton: .destructive(Text("Delete"), action: delete),
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .task {
            calculateScreen()
        }
        .onChange(of: experience.sortedIngestionsUnwrapped) { _ in
            calculateScreen()
            if #available(iOS 16.2, *) {
                if experience.isCurrent {
                    startOrUpdateLiveActivity()
                }
            }
        }
        .onChange(of: hiddenIngestions) { _ in
            calculateScreen()
        }
    }

    private func delete() {
        PersistenceController.shared.viewContext.delete(experience)
        PersistenceController.shared.saveViewContext()
        stopLiveActivity()
        dismiss()
    }

    private func calculateScreen() {
        setSubstances()
        calculateTimeline()
        calculateCumulativeDoses()
        findInteractions()
    }

    private func startOrUpdateLiveActivity() {
        if #available(iOS 16.2, *) {
            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: experience.sortedIngestionsUnwrapped))
        }
    }

    private func stopLiveActivity() {
        if #available(iOS 16.2, *) {
            if experience.isCurrent {
                ActivityManager.shared.stopActivity(everythingForEachLine: getEverythingForEachLine(from: experience.sortedIngestionsUnwrapped))
            }
        }
    }

    private func setSubstances() {
        self.substancesUsed = experience.sortedIngestionsUnwrapped
            .map { $0.substanceNameUnwrapped }
            .uniqued()
            .compactMap { SubstanceRepo.shared.getSubstance(name: $0) }
    }

    private func calculateTimeline() {
        let ingestionsToShow = experience.sortedIngestionsUnwrapped.filter {!hiddenIngestions.contains($0.id)}
        let everythingForEachLine = getEverythingForEachLine(from: ingestionsToShow)
        timelineModel = TimelineModel(everythingForEachLine: everythingForEachLine)
    }

    private func calculateCumulativeDoses() {
        let ingestionsBySubstance = Dictionary(grouping: experience.sortedIngestionsUnwrapped, by: { $0.substanceNameUnwrapped })
        let cumu: [CumulativeDose] = ingestionsBySubstance.compactMap { (substanceName: String, ingestions: [Ingestion]) in
            guard ingestions.count > 1 else {return nil}
            guard let color = ingestions.first?.substanceColor else {return nil}
            return CumulativeDose(ingestionsForSubstance: ingestions, substanceName: substanceName, substanceColor: color)
        }
        cumulativeDoses = cumu
    }

    private func findInteractions() {
        let substanceNames = experience.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }.uniqued()
        var interactions: [Interaction] = []
        for subIndex in 0..<substanceNames.count {
            let name = substanceNames[subIndex]
            let otherNames = substanceNames.dropFirst(subIndex+1)
            for otherName in otherNames {
                if let newInteraction = InteractionChecker.getInteractionBetween(aName: name, bName: otherName) {
                    interactions.append(newInteraction)
                }
            }
        }
        self.interactions = interactions.sorted(by: { interaction1, interaction2 in
            interaction1.interactionType.dangerCount > interaction2.interactionType.dangerCount
        })
    }

}

struct CumulativeDose: Identifiable {
    var id: String {
        substanceName
    }
    let substanceName: String
    let substanceColor: SubstanceColor
    let cumulativeRoutes: [CumulativeRouteAndDose]

    init(ingestionsForSubstance: [Ingestion], substanceName: String, substanceColor: SubstanceColor) {
        self.substanceName = substanceName
        self.substanceColor = substanceColor
        let substance = ingestionsForSubstance.first?.substance
        let ingestionsByRoute = Dictionary(grouping: ingestionsForSubstance, by: { $0.administrationRouteUnwrapped })
        self.cumulativeRoutes = ingestionsByRoute.map { (route: AdministrationRoute, ingestions: [Ingestion]) in
            let roaDose = substance?.getDose(for: route)
            return CumulativeRouteAndDose(route: route, roaDose: roaDose, ingestionForRoute: ingestions)
        }
    }
}

struct CumulativeRouteAndDose: Identifiable {
    var id: AdministrationRoute {
        route
    }
    let route: AdministrationRoute
    let numDots: Int?
    let isEstimate: Bool
    let dose: Double?
    let units: String

    init(route: AdministrationRoute, roaDose: RoaDose?, ingestionForRoute: [Ingestion]) {
        self.route = route
        let units = ingestionForRoute.first?.units ?? "unknown"
        self.units = units
        var totalDose = 0.0
        var isOneDoseUnknown = false
        var isOneDoseAnEstimate = false
        for ingestion in ingestionForRoute {
            if let doseUnwrap = ingestion.doseUnwrapped, ingestion.unitsUnwrapped == units {
                totalDose += doseUnwrap
                if ingestion.isEstimate {
                    isOneDoseAnEstimate = true
                }
            } else {
                isOneDoseUnknown = true
                break
            }
        }
        if isOneDoseUnknown {
            self.dose = nil
            self.isEstimate = isOneDoseAnEstimate
            self.numDots = nil
        } else {
            self.dose = totalDose
            self.isEstimate = isOneDoseAnEstimate
            self.numDots = roaDose?.getNumDots(ingestionDose: totalDose, ingestionUnits: units)
        }

    }

    init(route: AdministrationRoute, numDots: Int?, isEstimate: Bool, dose: Double?, units: String) {
        self.route = route
        self.numDots = numDots
        self.isEstimate = isEstimate
        self.dose = dose
        self.units = units
    }
}
