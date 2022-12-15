import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @State private var isShowingAddIngestionSheet = false

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    EffectTimeline(timelineModel: timelineModel)
                } header: {
                    Text("Effect Timeline")
                } footer: {
                    let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
                    Text(firstDate, style: .date)
                }
                Section("Ingestions") {
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        IngestionRow(
                            substanceColor: ing.substanceColor,
                            substanceName: ing.substanceNameUnwrapped,
                            dose: ing.doseUnwrapped,
                            units: ing.unitsUnwrapped,
                            isEstimate: ing.isEstimate,
                            administrationRoute: ing.administrationRouteUnwrapped,
                            ingestionTime: ing.timeUnwrapped,
                            note: ing.noteUnwrapped
                        )
                    }
                    .onDelete(perform: deleteIngestions)
                    Button {
                        isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("Add Ingestion", systemImage: "plus")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            Section("Notes") {
                if let notes = experience.textUnwrapped, !notes.isEmpty {
                    Text(notes)
                        .padding(.vertical, 5)
                } else {
                    NavigationLink {
                        EditExperience()
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
                NavigationLink {
                    EditExperience()
                } label: {
                    Label("Edit Experience", systemImage: "pencil")
                }
            }
        }
    }

    private func deleteIngestions(at offsets: IndexSet) {
        for offset in offsets {
            let ingestion = experience.sortedIngestionsUnwrapped[offset]
            PersistenceController.shared.viewContext.delete(ingestion)
        }
        PersistenceController.shared.saveViewContext()
    }

    var timelineModel: TimelineModel {
        TimelineModel(everythingForEachLine: experience.sortedIngestionsUnwrapped.map { ingestion in
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
}
