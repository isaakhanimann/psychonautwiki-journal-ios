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
        case editConsumer

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
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Cancel") {
                        dismiss()
                    }
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
        DoneButton {
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
                        self.generateSuccessHaptic()
                        self.dismiss()
                    }
                } catch {
                    Task { @MainActor in
                        self.toastViewModel.showErrorToast(message: "Failed Ingestion")
                        self.generateFailedHaptic()
                        self.dismiss()
                    }
                }
            }
        }
    }

    var screen: some View {
        Form {
            Section {
                DatePicker(
                    "Ingestion Time",
                    selection: $viewModel.selectedTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
                if viewModel.experiencesWithinLargerRange.count>0 {
                    NavigationLink {
                        ExperiencePickerScreen(
                            selectedExperience: $viewModel.selectedExperience,
                            wantsToForceNewExperience: $viewModel.wantsToForceNewExperience,
                            experiences: viewModel.experiencesWithinLargerRange
                        )
                    } label: {
                        HStack {
                            Text("Part of:")
                            Spacer()
                            if let exp = viewModel.selectedExperience {
                                Text(exp.titleUnwrapped)
                            } else {
                                Text("New Experience")
                            }
                        }
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
            } header: {
                HStack {
                    Text("Ingestion")
                    Spacer()
                    Button("Reset time") {
                        withAnimation {
                            viewModel.selectedTime = Date.now
                        }
                    }
                }
            }
            if viewModel.selectedExperience == nil {
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
                            Label(locationName, systemImage: "mappin")
                        } else {
                            Label("Add Location", systemImage: "plus")
                        }
                    }
                    if #available(iOS 16.2, *) {
                        let isTimeRecentOrFuture = Date().timeIntervalSinceReferenceDate - viewModel.selectedTime.timeIntervalSinceReferenceDate < 12*60*60
                        if ActivityManager.shared.authorizationInfo.areActivitiesEnabled && !ActivityManager.shared.isActivityActive && isTimeRecentOrFuture {
                            Toggle("Start Live Activity", isOn: $viewModel.wantsToStartLiveActivity).tint(.accentColor)
                        }
                    }
                }
            }
            if administrationRoute == .oral {
                EditStomachFullnessSection(stomachFullness: $viewModel.selectedStomachFullness)
            }
            Section("Consumer") {
                HStack {
                    Text("Consumer")
                    Spacer()
                    let displayedName = viewModel.isConsumerMe ? "Me" : viewModel.consumerName
                    Button(displayedName) {
                        sheetToShow = .editConsumer
                    }
                }
            }
            Section {
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
        .navigationBarTitle("Finish Ingestion")
        .sheet(item: $sheetToShow, content: { sheet in
            switch sheet {
            case .editTitle:
                ExperienceTitleScreen(title: $viewModel.enteredTitle)
            case .editNote:
                IngestionNoteScreen(note: $viewModel.enteredNote)
            case .editLocation:
                ChooseLocationScreen(locationManager: locationManager, onDone: {})
            case .editConsumer:
                EditConsumerScreen(consumerName: $viewModel.consumerName)
            }
        })
        .task {
            guard !viewModel.isInitialized else {return} // because this function is going to be called again when navigating back from color picker screen
            locationManager.selectedLocation = locationManager.currentLocation
            locationManager.selectedLocationName = locationManager.currentLocation?.name ?? ""
            viewModel.initializeColorCompanionAndNote(for: substanceName, suggestedNote: suggestedNote)
        }
    }

    func generateSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func generateFailedHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
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
