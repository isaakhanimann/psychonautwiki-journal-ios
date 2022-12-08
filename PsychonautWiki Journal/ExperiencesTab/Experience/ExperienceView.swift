import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @State private var isShowingAddIngestionSheet = false

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section("Ingestions") {
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        IngestionRow(ingestion: ing)
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
            ChooseSubstanceView()
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
}
