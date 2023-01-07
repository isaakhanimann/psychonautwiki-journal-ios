import SwiftUI

struct FinishIngestionScreen: View {

    let substanceName: String
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    let isEstimate: Bool
    let dismiss: () -> Void
    var suggestedNote: String? = nil
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @StateObject var viewModel = ViewModel()

    var body: some View {
        FinishIngestionContent(
            substanceName: substanceName,
            selectedTime: $viewModel.selectedTime,
            selectedExperience: $viewModel.selectedExperience,
            experiencesWithinLargerRange: viewModel.experiencesWithinLargerRange,
            wantsToCreateNewExperience: $viewModel.wantsToCreateNewExperience,
            enteredNote: $viewModel.enteredNote,
            enteredTitle: $viewModel.enteredTitle,
            selectedColor: $viewModel.selectedColor,
            alreadyUsedColors: viewModel.alreadyUsedColors,
            otherColors: viewModel.otherColors,
            addIngestion: {
                viewModel.addIngestion(
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
                dismiss()
                toastViewModel.showSuccessToast()
            },
            dismiss: dismiss,
            notesInOrder: viewModel.notesInOrder
        ).task {
            viewModel.initializeColorCompanionAndNote(for: substanceName, suggestedNote: suggestedNote)
        }
    }
}


struct FinishIngestionContent: View {

    let substanceName: String
    @Binding var selectedTime: Date
    @Binding var selectedExperience: Experience?
    var experiencesWithinLargerRange: [Experience]
    @Binding var wantsToCreateNewExperience: Bool
    @Binding var enteredNote: String
    @Binding var enteredTitle: String
    @Binding var selectedColor: SubstanceColor
    let alreadyUsedColors: Set<SubstanceColor>
    let otherColors: Set<SubstanceColor>
    let addIngestion: () -> Void
    let dismiss: () -> Void
    let notesInOrder: [String]
    @State private var isShowingIngestionNoteSheet = false

    var body: some View {
        Form {
            Section("Time") {
                DatePicker(
                    "Ingestion Time",
                    selection: $selectedTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
                if let selectedExperience {
                    if experiencesWithinLargerRange.count>1 {
                        if !wantsToCreateNewExperience {
                            NavigationLink {
                                ExperiencePickerScreen(
                                    selectedExperience: $selectedExperience,
                                    experiences: experiencesWithinLargerRange
                                )
                            } label: {
                                HStack {
                                    Text("Part of:")
                                    Spacer()
                                    Text(selectedExperience.titleUnwrapped)
                                }
                            }
                        }
                        Toggle("Create New Experience", isOn: $wantsToCreateNewExperience.animation()).tint(.accentColor)
                    } else {
                        Toggle("Part of \(selectedExperience.titleUnwrapped)", isOn: $wantsToCreateNewExperience.not).tint(.accentColor)
                    }
                }
            }
            if selectedExperience == nil || wantsToCreateNewExperience {
                Section("New Experience") {
                    if #available(iOS 16.0, *) {
                        TextField(
                            "Experience Title",
                            text: $enteredTitle,
                            prompt: Text("Enter Title"),
                            axis: .vertical
                        )
                        .lineLimit(2)
                        .submitLabel(.done)
                    } else {
                        TextField("Experience Title", text: $enteredTitle, prompt: Text("Enter Title"))
                            .submitLabel(.done)
                    }
                }
            }

            Section("Ingestion Note") {
                if enteredNote.isEmpty {
                    Button {
                        isShowingIngestionNoteSheet.toggle()
                    } label: {
                        Label("Add Note", systemImage: "plus")
                    }
                } else {
                    HStack {
                        Text(enteredNote).lineLimit(1)
                        Spacer()
                        Button {
                            isShowingIngestionNoteSheet.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil").labelStyle(.iconOnly)
                        }
                        .sheet(isPresented: $isShowingIngestionNoteSheet) {
                            IngestionNoteScreen(note: $enteredNote)
                        }
                    }
                }
            }
            Section("\(substanceName) Color") {
                NavigationLink {
                    ColorPickerScreen(
                        selectedColor: $selectedColor,
                        alreadyUsedColors: alreadyUsedColors,
                        otherColors: otherColors
                    )
                } label: {
                    HStack {
                        Text("\(substanceName) Color")
                        Spacer()
                        Image(systemName: "circle.fill").foregroundColor(selectedColor.swiftUIColor)
                    }
                }
            }
        }
        .optionalScrollDismissesKeyboard()
        .navigationBarTitle("Finish")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    addIngestion()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }

            }
        }
    }
}

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

struct FinishIngestionContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FinishIngestionContent(
                substanceName: "MDMA",
                selectedTime: .constant(Date()),
                selectedExperience: .constant(nil),
                experiencesWithinLargerRange: [],
                wantsToCreateNewExperience: .constant(false),
                enteredNote: .constant("hello"),
                enteredTitle: .constant("This is my title"),
                selectedColor: .constant(.green),
                alreadyUsedColors: [.blue, .brown, .pink],
                otherColors: [.green, .mint, .indigo, .cyan, .purple, .orange, .red, .teal],
                addIngestion: {},
                dismiss: {},
                notesInOrder: [
                    "The first note",
                    "Second note",
                    "This is a very long note that does not fit on one line and it should be clipped."
                ]
            )
        }
    }
}
