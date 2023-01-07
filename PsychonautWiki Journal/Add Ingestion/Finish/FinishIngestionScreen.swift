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
                    TextField("Experience Title", text: $enteredTitle, prompt: Text("Enter Title"))
                }
            }

            Section("Notes") {
                TextField("Notes", text: $enteredNote)
                    .autocapitalization(.sentences)
                ForEach(notesInOrder, id: \.self) { note in
                    Button {
                        enteredNote = note
                    } label: {
                        Label(note, systemImage: "doc.on.doc").lineLimit(1)
                    }.foregroundColor(.primary)
                }
            }
            Section("Color") {
                NavigationLink {
                    ColorPickerScreen(
                        selectedColor: $selectedColor,
                        alreadyUsedColors: alreadyUsedColors,
                        otherColors: otherColors
                    )
                } label: {
                    HStack {
                        Text("Color")
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
