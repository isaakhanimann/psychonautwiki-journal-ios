import SwiftUI

struct ExperienceScreen: View {

    @ObservedObject var experience: Experience
    @State private var isShowingAddIngestionSheet = false
    @State private var isTimeRelative = false
    @State private var timelineModel: TimelineModel?
    @State private var cumulativeDoses: [CumulativeDose] = []
    @State private var interactions: [Interaction] = []
    @State private var substancesUsed: [Substance] = []

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                if let timelineModelUnwrap = timelineModel {
                    Section {
                        EffectTimeline(timelineModel: timelineModelUnwrap)
                    } header: {
                        Text("Effect Timeline")
                    } footer: {
                        let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
                        Text(firstDate, style: .date)
                    }
                }
                Section("Ingestions") {
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
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
                            IngestionRow(
                                ingestion: ing,
                                roaDose: roaDose,
                                isTimeRelative: isTimeRelative
                            )
                        }
                    }
                    Button {
                        isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("Add Ingestion", systemImage: "plus")
                            .foregroundColor(.accentColor)
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
            if !interactions.isEmpty {
                Section("Interactions") {
                    ForEach(interactions) { interaction in
                        InteractionPairRow(
                            aName: interaction.aName,
                            bName: interaction.bName,
                            interactionType: interaction.interactionType
                        )
                    }
                    NavigationLink("See All") {
                        GoThroughAllInteractionsScreen(substancesToCheck: substancesUsed)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddIngestionSheet, content: {
            ChooseSubstanceScreen()
        })
        .navigationTitle(experience.titleUnwrapped)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    isTimeRelative.toggle()
                } label: {
                    Label("Relative Time", systemImage: "timer.circle" + (isTimeRelative ? ".fill" : ""))
                }
                NavigationLink("Edit") {
                    EditExperienceScreen(experience: experience)
                }
            }
        }
        .task {
            calculateScreen()
        }
        .onChange(of: experience.sortedIngestionsUnwrapped) { _ in
            calculateScreen()
        }
    }

    private func calculateScreen() {
        setSubstances()
        calculateTimeline()
        calculateCumulativeDoses()
        findInteractions()
    }

    private func setSubstances() {
        self.substancesUsed = experience.sortedIngestionsUnwrapped
            .map { $0.substanceNameUnwrapped }
            .uniqued()
            .compactMap { SubstanceRepo.shared.getSubstance(name: $0) }
    }

    private func calculateTimeline() {
        let dosePairs: [(String, Double)] = experience.sortedIngestionsUnwrapped.compactMap({ ing in
            guard let dose = ing.doseUnwrapped else {return nil}
            return (ing.substanceNameUnwrapped, dose)
        })
        let maxDoses = Dictionary(dosePairs) { dose1, dose2 in
            max(dose1, dose2)
        }
        timelineModel = TimelineModel(everythingForEachLine: experience.sortedIngestionsUnwrapped.map { ingestion in
            let substanceName = ingestion.substanceNameUnwrapped
            let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
            let roaDuration = substance?.getDuration(for: ingestion.administrationRouteUnwrapped)
            let roaDose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
            var horizontalWeight = 0.5
            if let dose = ingestion.doseUnwrapped, let units = ingestion.units, let roaDose {
                let doseType = roaDose.getRangeType(for: dose, with: units)
                switch doseType {
                case .thresh:
                    horizontalWeight = 0
                case .light:
                    horizontalWeight = 0.25
                case .common:
                    horizontalWeight = 0.5
                case .strong:
                    horizontalWeight = 0.75
                case .heavy:
                    horizontalWeight = 1
                case .none:
                    horizontalWeight = 0.5
                }
            }
            var verticalWeight = 1.0
            if let dose = ingestion.doseUnwrapped, let max = maxDoses[substanceName] {
                verticalWeight = dose/max
            }
            return EverythingForOneLine(
                roaDuration: roaDuration,
                startTime: ingestion.timeUnwrapped,
                horizontalWeight: horizontalWeight,
                verticalWeight: verticalWeight,
                color: ingestion.substanceColor.swiftUIColor
            )
        })
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
        let substanceNames = experience.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }
        let allNames = (substanceNames + InteractionChecker.additionalInteractionsToCheck).uniqued()
        var interactions: [Interaction] = []
        for subIndex in 0..<allNames.count {
            let name = allNames[subIndex]
            let otherNames = allNames.dropFirst(subIndex+1)
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
