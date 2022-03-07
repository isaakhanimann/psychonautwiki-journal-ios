import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $viewModel.selectedTitle)
            }
            Section(header: Text("Ingestions")) {
                ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                    .onDelete(perform: deleteIngestions)

                Button(action: showOrHideAddIngestionSheet) {
                    Label("Add Ingestion", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            if !experience.sortedIngestionsToDraw.isEmpty {
                Section(header: Text("Timeline")) {
                    HorizontalScaleView {
                        IngestionTimeLineView(sortedIngestions: experience.sortedIngestionsToDraw)
                    }
                    .frame(height: 310)
                }
            }
            if !experience.ingestionsWithDistinctSubstances.isEmpty {
                Section(header: Text("Substances")) {
                    ForEach(experience.ingestionsWithDistinctSubstances) { ing in
                        IngestionSubstanceRow(ingestion: ing)
                    }
                }
            }
            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.writtenText)
            }
            CalendarSection(experience: experience)
        }
        .task {
            viewModel.initialize(experience: experience)
        }
        .navigationTitle(viewModel.selectedTitle)
        .onDisappear {
            PersistenceController.shared.saveViewContext()
        }
        .sheet(isPresented: $viewModel.isShowingAddIngestionSheet) {
            ChooseSubstanceView(
                dismiss: showOrHideAddIngestionSheet,
                experience: experience
            )
                .accentColor(Color.blue)
        }
    }

    private func showOrHideAddIngestionSheet() {
        viewModel.isShowingAddIngestionSheet.toggle()
    }

    private func deleteIngestions(at offsets: IndexSet) {
        for offset in offsets {
            let ingestion = experience.sortedIngestionsUnwrapped[offset]
            PersistenceController.shared.viewContext.delete(ingestion)
        }
        PersistenceController.shared.saveViewContext()
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView(experience: PreviewHelper.shared.experiences.first!)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
