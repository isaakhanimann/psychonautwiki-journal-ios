import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var sheetViewModel: SheetViewModel
    @Environment(\.editMode) private var editMode

    var body: some View {
        let isEditing = editMode?.wrappedValue.isEditing == true
        return List {
            if isEditing {
                Section("Title") {
                    TextField("Title", text: $viewModel.selectedTitle)
                }
            }
            if !isEditing || !experience.sortedIngestionsUnwrapped.isEmpty {
                Section("Ingestions") {
                    ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                        .onDelete(perform: deleteIngestions)
                    if !isEditing {
                        Button {
                            sheetViewModel.sheetToShow = .addIngestionFromExperience(experience: experience)
                        } label: {
                            Label("Add Ingestion", systemImage: "plus")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            if !experience.sortedIngestionsToDraw.isEmpty && !isEditing {
                Section("Timeline") {
                    HorizontalScaleView {
                        IngestionTimeLineView(experience: experience)
                    }
                    .frame(height: 310)
                }
            }
            if !experience.substancesWithDose.isEmpty && !isEditing {
                Section("Substances") {
                    ForEach(experience.substancesWithDose) { subDos in
                        SubstanceDoseRow(substanceDose: subDos)
                    }
                }
            }
            if !viewModel.writtenText.isEmpty || isEditing {
                Section("Notes") {
                    if isEditing {
                        TextEditor(text: $viewModel.writtenText)
                            .frame(minHeight: 300)
                    } else {
                        Text(viewModel.writtenText)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 5)
                    }
                }
            }
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                CalendarSection(experience: experience)
            }
        }
        .task {
            viewModel.initialize(experience: experience)
        }
        .navigationTitle(experience.titleUnwrapped)
        .onChange(of: editMode?.wrappedValue) { newValue in
            guard let isEditing = newValue?.isEditing else {return}
            if !isEditing {
                PersistenceController.shared.saveViewContext()
            }
        }
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
                EditButton()
            }
        }
    }

    private func deleteIngestions(at offsets: IndexSet) {
        for offset in offsets {
            let ingestion = experience.sortedIngestionsUnwrapped[offset]
            PersistenceController.shared.viewContext.delete(ingestion)
        }
        PersistenceController.shared.saveViewContext()
        if experience.sortedIngestionsUnwrapped.isEmpty {
            editMode?.wrappedValue = .inactive
        }
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceView(experience: PreviewHelper.shared.experiences.first!)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
