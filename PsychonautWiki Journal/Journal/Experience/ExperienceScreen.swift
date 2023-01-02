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
    @State private var isShowingEditScreen = false
    @State private var hiddenIngestions: [ObjectIdentifier] = []

    @Environment(\.dismiss) var dismiss

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    let timelineHeight: Double = 200
                    if let timelineModelUnwrap = timelineModel {
                        EffectTimeline(timelineModel: timelineModelUnwrap, height: timelineHeight)
                    } else {
                        Canvas {_,_ in }.frame(height: timelineHeight)
                    }
                } header: {
                    let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
                    Text(firstDate, style: .date)
                }
                Section("Ingestions") {
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        let isIngestionHidden = hiddenIngestions.contains(ing.id)
                        let route = ing.administrationRouteUnwrapped
                        let roaDose = ing.substance?.getDose(for: route)
                        NavigationLink {
                            EditIngestionScreen(
                                ingestion: ing,
                                substanceName: ing.substanceNameUnwrapped,
                                roaDose: roaDose,
                                route: route
                            )
                        } label: {
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
                }
                if !cumulativeDoses.isEmpty {
                    Section("Cumulative Doses") {
                        ForEach(cumulativeDoses) { cumulative in
                            CumulativeDoseRow(
                                substanceName: cumulative.substanceName,
                                substanceColor: cumulative.substanceColor,
                                cumulativeRoutes: cumulative.cumulativeRoutes
                            )
                        }
                    }

                }
            }
            Section("Notes") {
                if let notes = experience.textUnwrapped, !notes.isEmpty {
                    Text(notes)
                        .padding(.vertical, 5)
                } else {
                    NavigationLink {
                        EditExperienceScreen(experience: experience)
                    } label: {
                        Label("Add Note", systemImage: "pencil")
                    }.foregroundColor(.accentColor)
                }
            }
            if !substancesUsed.isEmpty {
                Section("Substances") {
                    ForEach(substancesUsed) { substance in
                        NavigationLink(substance.name) {
                            SubstanceScreen(substance: substance)
                        }
                    }
                }
            }
            Section("Interactions") {
                ForEach(interactions) { interaction in
                    InteractionPairRow(
                        aName: interaction.aName,
                        bName: interaction.bName,
                        interactionType: interaction.interactionType
                    )
                }
                NavigationLink("See All Interactions") {
                    GoThroughAllInteractionsScreen(substancesToCheck: substancesUsed)
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
        .toolbar {
            ToolbarItemGroup {
                NavigationLink(
                    destination: EditExperienceScreen(experience: experience),
                    isActive: $isShowingEditScreen
                ) {
                    EmptyView()
                }
                Menu {
                    Button {
                        isShowingEditScreen.toggle()
                    } label: {
                        Label("Edit Title/Note", systemImage: "pencil")
                    }
                    let isFavorite = experience.isFavorite
                    Button {
                        experience.isFavorite = !isFavorite
                        try? PersistenceController.shared.viewContext.save()
                    } label: {
                        if isFavorite {
                            Label("Mark as Favorite", systemImage: "checkmark")
                        } else {
                            Text("Mark as Favorite")
                        }
                    }
                    Button {
                        isTimeRelative.toggle()
                    } label: {
                        if isTimeRelative {
                            Label("Show Relative Time", systemImage: "checkmark")
                        } else {
                            Text("Show Relative Time")
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
                    Spacer()
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
