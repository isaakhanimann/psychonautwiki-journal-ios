import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @State private var selectedTitle: String
    @State private var isShowingAddIngestionSheet = false
    @State private var writtenText: String

    init(experience: Experience) {
        self.experience = experience
        _selectedTitle = State(wrappedValue: experience.titleUnwrapped)
        _writtenText = State(wrappedValue: experience.textUnwrapped)
    }

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $selectedTitle)
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
                TextEditor(text: $writtenText)
            }
            CalendarSection(experience: experience)
        }
        .navigationTitle(selectedTitle)
        .onChange(of: selectedTitle) { _ in update() }
        .onChange(of: writtenText) { _ in update() }
        .onDisappear {
            PersistenceController.shared.saveViewContext()
        }
        .sheet(isPresented: $isShowingAddIngestionSheet) {
            ChooseSubstanceView(
                dismiss: showOrHideAddIngestionSheet,
                experience: experience
            )
                .accentColor(Color.blue)
        }
    }

    private func showOrHideAddIngestionSheet() {
        isShowingAddIngestionSheet.toggle()
    }

    private func deleteIngestions(at offsets: IndexSet) {
        for offset in offsets {
            let ingestion = experience.sortedIngestionsUnwrapped[offset]
            PersistenceController.shared.viewContext.delete(ingestion)
        }
        PersistenceController.shared.saveViewContext()
    }

    private func update() {
        experience.objectWillChange.send()
        experience.title = selectedTitle
        experience.text = writtenText
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView(experience: PreviewHelper.shared.experiences.first!)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
