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
    @StateObject var locationManager = LocationManager()

    var body: some View {
        Form {
            Section("Ingestion") {
                DatePicker(
                    "Ingestion Time",
                    selection: $viewModel.selectedTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
                if let selectedExperience = viewModel.selectedExperience {
                    if viewModel.experiencesWithinLargerRange.count>1 {
                        if !viewModel.wantsToCreateNewExperience {
                            NavigationLink {
                                ExperiencePickerScreen(
                                    selectedExperience: $viewModel.selectedExperience,
                                    experiences: viewModel.experiencesWithinLargerRange
                                )
                            } label: {
                                HStack {
                                    Text("Part of:")
                                    Spacer()
                                    Text(selectedExperience.titleUnwrapped)
                                }
                            }
                        }
                        Toggle("Create New Experience", isOn: $viewModel.wantsToCreateNewExperience.animation()).tint(.accentColor)
                    } else {
                        Toggle("Part of \(selectedExperience.titleUnwrapped)", isOn: $viewModel.wantsToCreateNewExperience.not).tint(.accentColor)
                    }
                }
                NavigationLink {
                    IngestionNoteScreen(note: $viewModel.enteredNote)
                } label: {
                    if viewModel.enteredNote.isEmpty {
                        Label("Add Note", systemImage: "plus")
                    } else {
                        Text(viewModel.enteredNote).lineLimit(1)
                    }
                }
            }
            if viewModel.selectedExperience == nil || viewModel.wantsToCreateNewExperience {
                Section("New Experience") {
                    NavigationLink {
                        ExperienceTitleScreen(title: $viewModel.enteredTitle)
                    } label: {
                        if viewModel.enteredTitle.isEmpty {
                            Label("Add Title", systemImage: "plus")
                        } else {
                            Text(viewModel.enteredTitle).lineLimit(1)
                        }
                    }
                    NavigationLink {
                        ChooseLocationScreen(locationManager: locationManager)
                    } label: {
                        if let locationName = locationManager.selectedLocation?.name {
                            Label(locationName, systemImage: "location")
                        } else {
                            Label("Add Location", systemImage: "plus")
                        }
                    }
                }
            }
            Section("\(substanceName) Color") {
                NavigationLink {
                    ColorPickerScreen(
                        selectedColor: $viewModel.selectedColor,
                        alreadyUsedColors: viewModel.alreadyUsedColors,
                        otherColors: viewModel.otherColors
                    )
                } label: {
                    HStack {
                        Text("\(substanceName) Color")
                        Spacer()
                        Image(systemName: "circle.fill").foregroundColor(viewModel.selectedColor.swiftUIColor)
                    }
                }
            }
        }
        .navigationBarTitle("Finish")
        .task {
            viewModel.initializeColorCompanionAndNote(for: substanceName, suggestedNote: suggestedNote)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        do {
                            try await viewModel.addIngestion(
                                substanceName: substanceName,
                                administrationRoute: administrationRoute,
                                dose: dose,
                                units: units,
                                isEstimate: isEstimate,
                                location: locationManager.selectedLocation
                            )
                            Task { @MainActor in
                                self.toastViewModel.showSuccessToast()
                                self.dismiss()
                            }
                        } catch {
                            Task { @MainActor in
                                self.toastViewModel.showErrorToast(message: "Failed Ingestion")
                                self.dismiss()
                            }
                        }
                    }
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
