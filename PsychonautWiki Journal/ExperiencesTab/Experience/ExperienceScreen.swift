import SwiftUI

struct ExperienceScreen: View {

    @ObservedObject var experience: Experience
    @State private var isShowingAddIngestionSheet = false
    @State private var timelineModel: TimelineModel?
    @State private var cumulativeDoses: [CumulativeDose] = []

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
                            IngestionRow(ingestion: ing, roaDose: roaDose)
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
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddIngestionSheet, content: {
            ChooseSubstanceScreen()
        })
        .navigationTitle(experience.titleUnwrapped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Edit") {
                    EditExperienceScreen(experience: experience)
                }
            }
        }
        .onAppear {
            calculateScreen()
        }
        .onChange(of: experience.sortedIngestionsUnwrapped) { _ in
            calculateScreen()
        }
    }

    private func calculateScreen() {
        calculateTimeline()
        calculateCumulativeDoses()
    }

    private func calculateTimeline() {
        timelineModel = TimelineModel(everythingForEachLine: experience.sortedIngestionsUnwrapped.map { ingestion in
            let substance = SubstanceRepo.shared.getSubstance(name: ingestion.substanceNameUnwrapped)
            let roaDuration = substance?.getDuration(for: ingestion.administrationRouteUnwrapped)
            return EverythingForOneLine(
                roaDuration: roaDuration,
                startTime: ingestion.timeUnwrapped,
                horizontalWeight: 0.5,
                verticalWeight: 1,
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
