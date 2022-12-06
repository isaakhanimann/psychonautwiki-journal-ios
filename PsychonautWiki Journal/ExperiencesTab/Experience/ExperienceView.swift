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
                        .disableAutocorrection(true)
                }
            }
            if !isEditing || !experience.sortedIngestionsUnwrapped.isEmpty {
                Section("Ingestions") {

                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        IngestionRow(ingestion: ing)
                            .deleteDisabled(!isEditing)
                    }
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
        }
        .task {
            viewModel.initialize(experience: experience)
        }
        .navigationTitle(experience.titleUnwrapped)
        .onChange(of: editMode?.wrappedValue) { newValue in
            guard let isEditing = newValue?.isEditing else {return}
            if !isEditing {
                hideKeyboard()
                PersistenceController.shared.saveViewContext()
            }
        }
        .onDisappear {
            PersistenceController.shared.saveViewContext()
        }
        .toolbar {
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
