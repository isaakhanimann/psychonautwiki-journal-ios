import SwiftUI

struct IngestionsTab: View {

    @ObservedObject var experience: Experience
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @State private var isShowingAddIngestionSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                    .onDelete(perform: deleteIngestions)
            }
            .navigationTitle("Ingestions")
            .toolbar {
                ToolbarItemGroup(placement: ToolbarItemPlacement.primaryAction) {
                    Button(action: addIngestion) {
                        Label("Add Ingestion", systemImage: "plus")
                    }
                    if !experience.sortedIngestionsUnwrapped.isEmpty {
                        Button(action: deleteAllIngestions) {
                            Label("Restart", systemImage: "restart")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddIngestionSheet) {
                ChooseSubstanceView(
                    substancesFile: storedFile.first!,
                    dismiss: {isShowingAddIngestionSheet.toggle()},
                    experience: experience
                )
                .environment(\.managedObjectContext, self.moc)
                .accentColor(Color.blue)
            }
        }
    }

    private func addIngestion() {
        isShowingAddIngestionSheet.toggle()
    }

    private func deleteAllIngestions() {
        withAnimation {
            moc.perform {
                for ingestion in experience.sortedIngestionsUnwrapped {
                    moc.delete(ingestion)
                }
                try? moc.save()
            }
        }
    }

    private func deleteIngestions(at offsets: IndexSet) {
        withAnimation {
            moc.perform {
                for offset in offsets {
                    let ingestion = experience.sortedIngestionsUnwrapped[offset]
                    moc.delete(ingestion)
                }
                try? moc.save()
            }
        }
    }

}

struct IngestionsTab_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        IngestionsTab(experience: helper.experiences.first!)
    }
}
