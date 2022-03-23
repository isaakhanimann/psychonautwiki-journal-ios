import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var sheetViewModel: SheetViewModel

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $viewModel.selectedTitle)
            }
            Section(header: Text("Ingestions")) {
                ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                    .onDelete(perform: deleteIngestions)

                Button {
                    sheetViewModel.sheetToShow = .addIngestionFromExperience(experience: experience)
                } label: {
                    Label("Add Ingestion", systemImage: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            if !experience.sortedIngestionsToDraw.isEmpty {
                Section(header: Text("Timeline")) {
                    HorizontalScaleView {
                        IngestionTimeLineView(experience: experience)
                    }
                    .frame(height: 310)
                }
            }
            if !experience.substancesWithDose.isEmpty {
                Section("Substances") {
                    ForEach(experience.substancesWithDose) { subDos in
                        SubstanceDoseRow(substanceDose: subDos)
                    }
                }
            }
            noteSection
            CalendarSection(experience: experience)
        }
        .task {
            viewModel.initialize(experience: experience)
        }
        .navigationTitle(experience.titleUnwrapped)
        .onDisappear {
            PersistenceController.shared.saveViewContext()
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
            ToolbarItem(placement: .navigation) {
                if !experience.sortedIngestionsUnwrapped.isEmpty {
                    EditButton()
                }
            }
        }
    }

    private var noteSection: some View {
        Section(header: Text("Notes")) {
            ZStack {
                TextEditor(text: $viewModel.writtenText)
                // this makes sure that the texteditor has a dynamic height
                Text(viewModel.writtenText).opacity(0).padding(.all, 8)
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

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView(experience: PreviewHelper.shared.experiences.first!)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
