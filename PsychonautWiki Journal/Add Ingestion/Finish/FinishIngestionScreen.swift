// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct FinishIngestionScreen: View {

    enum SheetOption: Identifiable {
        case editTitle
        case editNote
        case editLocation

        var id: Self {
            self
        }
    }

    let substanceName: String
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    let isEstimate: Bool
    let dismiss: () -> Void
    var suggestedNote: String? = nil
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var locationManager: LocationManager
    @State private var sheetToShow: SheetOption? = nil

    var body: some View {
        if #available(iOS 16, *) {
            screen.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    doneButton
                }
            }
        } else {
            screen.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    doneButton
                }
            }
        }
    }

    var doneButton: some View {
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

    var screen: some View {
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
                Button {
                    sheetToShow = .editNote
                } label: {
                    if viewModel.enteredNote.isEmpty {
                        Label("Add Note", systemImage: "plus")
                    } else {
                        Label(viewModel.enteredNote, systemImage: "pencil").lineLimit(1)
                    }
                }
            }
            if viewModel.selectedExperience == nil || viewModel.wantsToCreateNewExperience {
                Section("New Experience") {
                    Button {
                        sheetToShow = .editTitle
                    } label: {
                        if viewModel.enteredTitle.isEmpty {
                            Label("Add Title", systemImage: "plus")
                        } else {
                            Label(viewModel.enteredTitle, systemImage: "pencil").lineLimit(1)
                        }
                    }
                    Button {
                        sheetToShow = .editLocation
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
        .sheet(item: $sheetToShow, content: { sheet in
            switch sheet {
            case .editTitle:
                ExperienceTitleScreen(title: $viewModel.enteredTitle)
            case .editNote:
                IngestionNoteScreen(note: $viewModel.enteredNote)
            case .editLocation:
                ChooseLocationScreen(locationManager: locationManager)
            }
        })
        .task {
            guard !viewModel.isInitialized else {return} // because this function is going to be called again when navigating back from color picker screen
            locationManager.selectedLocation = locationManager.currentLocation
            locationManager.selectedLocationName = locationManager.currentLocation?.name ?? ""
            viewModel.initializeColorCompanionAndNote(for: substanceName, suggestedNote: suggestedNote)
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
