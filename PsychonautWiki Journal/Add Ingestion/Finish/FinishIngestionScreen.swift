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

import CoreData
import SwiftUI

// swiftlint:disable type_body_length function_body_length file_length

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

    let arguments: FinishIngestionScreenArguments
    let dismiss: () -> Void

    @EnvironmentObject private var toastViewModel: ToastViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @State private var sheetToShow: SheetOption?
    @State private var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
    @State private var selectedTime = Date()
    @State private var selectedTimePickerOption = TimePickerOption.pointInTime
    @State private var selectedEndTime = Date().addingTimeInterval(30*60)
    @State private var enteredNote = ""
    @State private var enteredTitle = ""
    @State private var consumerName = ""
    @State private var selectedStomachFullness = StomachFullness.empty
    @State private var alreadyUsedColors = [SubstanceColor]()
    @State private var otherColors = [SubstanceColor]()
    @State private var foundCompanion: SubstanceCompanion?

    @State private var experiencesWithinLargerRange: [Experience] = []
    @State private var selectedExperience: Experience?
    @State private var wantsToForceNewExperience = false
    @State private var wantsToStartLiveActivity = true
    @AppStorage(PersistenceController.areRedosesDrawnIndividuallyKey) var areRedosesDrawnIndividually = false
    @AppStorage(PersistenceController.independentSubstanceHeightKey) var areSubstanceHeightsIndependent = false
    @AppStorage(PersistenceController.shouldAutomaticallyStartLiveActivityKey) var shouldAutomaticallyStartLiveActivity: Bool = true

    var areYouConsumer: Bool {
        consumerName.isEmpty || consumerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
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

    var doneButton: some View {
        DoneButton {
            Task {
                do {
                    try await addIngestionWithExperience()
                    Task { @MainActor in
                        toastViewModel.showSuccessToast()
                        generateSuccessHaptic()
                        dismiss()
                    }
                } catch {
                    Task { @MainActor in
                        toastViewModel.showErrorToast(message: "Failed Ingestion")
                        generateFailedHaptic()
                        dismiss()
                    }
                }
            }
        }
    }

    var screen: some View {
        Form {
            Section("Ingestion") {
                TimePointOrRangePicker(
                    selectedTimePickerOption: $selectedTimePickerOption,
                    selectedTime: $selectedTime,
                    selectedEndTime: $selectedEndTime
                )
                if experiencesWithinLargerRange.count > 0 {
                    NavigationLink {
                        ExperiencePickerScreen(
                            selectedExperience: $selectedExperience,
                            wantsToForceNewExperience: $wantsToForceNewExperience,
                            experiences: experiencesWithinLargerRange)
                    } label: {
                        HStack {
                            Text("Experience")
                            Spacer()
                            if let exp = selectedExperience {
                                Text(exp.titleUnwrapped)
                            } else {
                                Text("New Experience")
                            }
                        }
                    }
                }
                HStack {
                    Text("Consumer")
                    Spacer()
                    Button {
                        sheetToShow = .editConsumer
                    } label: {
                        let displayedName = areYouConsumer ? "You" : consumerName
                        Label(displayedName, systemImage: "person")
                    }
                }
                if arguments.administrationRoute == .oral {
                    StomachFullnessPicker(stomachFullness: $selectedStomachFullness)
                        .pickerStyle(.navigationLink)
                        .labelsHidden()
                }
                Button {
                    sheetToShow = .editNote
                } label: {
                    if enteredNote.isEmpty {
                        Label("Add Note", systemImage: "plus")
                    } else {
                        Label(enteredNote, systemImage: "pencil").lineLimit(1)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .onChange(of: selectedTime) { _ in
                selectExperienceBasedOnCurrentTime()
            }
            if selectedExperience == nil {
                Section("New Experience") {
                    Button {
                        sheetToShow = .editTitle
                    } label: {
                        if enteredTitle.isEmpty {
                            Label("Add Title", systemImage: "plus")
                        } else {
                            Label(enteredTitle, systemImage: "pencil").lineLimit(1)
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
                        let isTimeRecentOrFuture = Date().timeIntervalSinceReferenceDate - selectedTime
                            .timeIntervalSinceReferenceDate < 12 * 60 * 60
                        if
                            ActivityManager.shared.authorizationInfo.areActivitiesEnabled,
                            !ActivityManager.shared.isActivityActive,
                            isTimeRecentOrFuture
                        {
                            Toggle("Start Live Activity", isOn: $wantsToStartLiveActivity).tint(.accentColor)
                        }
                    }
                }
            }
            Section {
                NavigationLink {
                    ColorPickerScreen(
                        selectedColor: $selectedColor,
                        alreadyUsedColors: alreadyUsedColors,
                        otherColors: otherColors)
                } label: {
                    HStack {
                        Text("\(arguments.substanceName) Color")
                        Spacer()
                        Image(systemName: "circle.fill").foregroundColor(selectedColor.swiftUIColor)
                    }
                }
            }
        }
        .onAppear {
            wantsToStartLiveActivity = shouldAutomaticallyStartLiveActivity
            generator.prepare()
        }
        .navigationBarTitle("Finish Ingestion")
        .sheet(item: $sheetToShow, content: { sheet in
            switch sheet {
            case .editTitle:
                ExperienceTitleScreen(title: $enteredTitle)
            case .editNote:
                IngestionNoteScreen(note: $enteredNote)
            case .editLocation:
                ChooseLocationScreen(locationManager: locationManager, onDone: { })
            case .editConsumer:
                EditConsumerScreen(consumerName: $consumerName)
            }
        })
        .onFirstAppear { // because onAppear is called again when navigating back from color picker screen
            let lastIngestionTimeIntervalSince1970 = UserDefaults.standard.double(forKey: PersistenceController.lastIngestionTimeOfExperienceWhereAddIngestionTappedKey)
            let clonedIngestionTimeIntervalSince1970 = UserDefaults.standard.double(forKey: PersistenceController.clonedIngestionTimeKey)
            if clonedIngestionTimeIntervalSince1970 != 0 {
                let clonedTime = Date(timeIntervalSince1970: clonedIngestionTimeIntervalSince1970)
                selectedTime = clonedTime
                selectedEndTime = clonedTime.addingTimeInterval(30*60)
            } else if lastIngestionTimeIntervalSince1970 != 0 {
                let lastIngestionTimeOfExperienceWhereAddIngestionTapped = Date(timeIntervalSince1970: lastIngestionTimeIntervalSince1970)
                let hoursSince = lastIngestionTimeOfExperienceWhereAddIngestionTapped.distance(to: .now)/(60*60)
                if hoursSince > 20 {
                    selectedTime = lastIngestionTimeOfExperienceWhereAddIngestionTapped
                    selectedEndTime = lastIngestionTimeOfExperienceWhereAddIngestionTapped.addingTimeInterval(30*60)
                }
            }

            selectExperienceBasedOnCurrentTime()
            locationManager.selectedLocation = locationManager.currentLocation
            locationManager.selectedLocationName = locationManager.currentLocation?.name ?? ""
            initializeColorCompanionAndNote()
        }
    }

    func selectExperienceBasedOnCurrentTime() {
        let fetchRequest = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false)]
        fetchRequest.predicate = FinishIngestionScreen.getPredicate(from: selectedTime)
        experiencesWithinLargerRange = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
        if wantsToForceNewExperience {
            selectedExperience = nil
        } else {
            selectedExperience = FinishIngestionScreen.getClosestExperience(
                from: experiencesWithinLargerRange,
                date: selectedTime)
        }
    }

    func initializeColorCompanionAndNote() {
        let fetchRequest = SubstanceCompanion.fetchRequest()
        let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
        alreadyUsedColors = Array(Set(companions.map { $0.color })).sorted()
        otherColors = Array(Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)).sorted()
        let companionMatch = companions.first { comp in
            comp.substanceNameUnwrapped == arguments.substanceName
        }
        if let companionMatchUnwrap = companionMatch {
            foundCompanion = companionMatchUnwrap
            selectedColor = companionMatchUnwrap.color
        } else {
            selectedColor = otherColors.filter { $0.isPreferred }.first ?? otherColors.first ?? SubstanceColor.allCases
                .randomElement() ?? SubstanceColor.blue
        }
    }

    func addIngestionWithExperience() async throws {
        let context = PersistenceController.shared.viewContext
        try await context.perform {
            if let existingExperience = selectedExperience {
                createIngestionWithCompanion(
                    with: existingExperience,
                    and: context)
                if #available(iOS 16.2, *) {
                    if existingExperience.isCurrent, ActivityManager.shared.isActivityActive {
                        Task {
                            await ActivityManager.shared.startOrUpdateActivity(
                                substanceGroups: getSubstanceIngestionGroups(ingestions: existingExperience.myIngestionsSorted),
                                everythingForEachRating: existingExperience.ratingsWithTimeSorted.map { shulgin in
                                    EverythingForOneRating(
                                        time: shulgin.timeUnwrapped,
                                        option: shulgin.optionUnwrapped)
                                },
                                everythingForEachTimedNote: existingExperience.timedNotesSorted.filter { $0.isPartOfTimeline }
                                    .map { timedNote in
                                        EverythingForOneTimedNote(
                                            time: timedNote.timeUnwrapped,
                                            color: timedNote.color)
                                    },
                                areRedosesDrawnIndividually: areRedosesDrawnIndividually,
                                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
                            )
                        }
                    }
                }
            } else {
                let newExperience = Experience(context: context)
                newExperience.creationDate = Date()
                newExperience.sortDate = selectedTime
                var title = selectedTime.asDateString
                if !enteredTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    title = enteredTitle
                }
                newExperience.title = title
                newExperience.text = ""
                if let location = locationManager.selectedLocation {
                    let newLocation = ExperienceLocation(context: context)
                    newLocation.name = location.name
                    newLocation.latitude = location.latitude ?? 0
                    newLocation.longitude = location.longitude ?? 0
                    newLocation.experience = newExperience
                }
                createIngestionWithCompanion(
                    with: newExperience,
                    and: context)
                if #available(iOS 16.2, *) {
                    if newExperience.isCurrent, self.wantsToStartLiveActivity {
                        Task {
                            await ActivityManager.shared.startOrUpdateActivity(
                                substanceGroups: getSubstanceIngestionGroups(ingestions: newExperience.myIngestionsSorted),
                                everythingForEachRating: [],
                                everythingForEachTimedNote: [],
                                areRedosesDrawnIndividually: areRedosesDrawnIndividually,
                                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
                            )
                        }
                    }
                }
            }
            try context.save()
        }
    }

    private func createOrUpdateCompanion(with context: NSManagedObjectContext) -> SubstanceCompanion {
        if let foundCompanion {
            foundCompanion.colorAsText = selectedColor.rawValue
            return foundCompanion
        } else {
            let companion = SubstanceCompanion(context: context)
            companion.substanceName = arguments.substanceName
            companion.colorAsText = selectedColor.rawValue
            return companion
        }
    }

    private func createIngestionWithCompanion(
        with experience: Experience,
        and context: NSManagedObjectContext)
    {
        let ingestion = Ingestion(context: context)
        ingestion.identifier = UUID()
        ingestion.time = selectedTime
        if selectedTimePickerOption == .timeRange {
            ingestion.endTime = selectedEndTime
        } else {
            ingestion.endTime = nil
        }
        ingestion.creationDate = Date()
        ingestion.customUnit = arguments.customUnit
        ingestion.dose = arguments.dose ?? 0
        ingestion.units = arguments.units
        ingestion.isEstimate = arguments.isEstimate
        ingestion.estimatedDoseStandardDeviation = arguments.estimatedDoseStandardDeviation ?? 0
        ingestion.note = enteredNote
        ingestion.administrationRoute = arguments.administrationRoute.rawValue
        ingestion.substanceName = arguments.substanceName
        ingestion.color = selectedColor.rawValue
        if !areYouConsumer {
            ingestion.consumerName = consumerName
        }
        if arguments.administrationRoute == .oral {
            ingestion.stomachFullness = selectedStomachFullness.rawValue
        } else {
            ingestion.stomachFullness = nil
        }
        ingestion.experience = experience
        let companion = createOrUpdateCompanion(with: context)
        ingestion.substanceCompanion = companion
    }

    private static func getClosestExperience(from experiences: [Experience], date: Date) -> Experience? {
        let fifteenHours: TimeInterval = 15 * 60 * 60
        let threeHours: TimeInterval = 3 * 60 * 60
        return experiences.first { exp in
            let experienceStart = exp.ingestionsSorted.first?.time ?? exp.sortDateUnwrapped
            let lastIngestionTime = exp.ingestionsSorted.last?.time ?? exp.sortDateUnwrapped
            let experienceRange = experienceStart.addingTimeInterval(-threeHours) ... max(experienceStart.addingTimeInterval(fifteenHours), lastIngestionTime.addingTimeInterval(threeHours))
            return experienceRange.contains(date)
        }
    }

    static func getPredicate(from date: Date) -> NSCompoundPredicate {
        let longInterval: TimeInterval = 60 * 60 * 60
        let startDate = date.addingTimeInterval(-longInterval)
        let endDate = date.addingTimeInterval(longInterval)
        let laterThanStart = NSPredicate(format: "sortDate > %@", startDate as NSDate)
        let earlierThanEnd = NSPredicate(format: "sortDate < %@", endDate as NSDate)
        return NSCompoundPredicate(
            andPredicateWithSubpredicates: [laterThanStart, earlierThanEnd])
    }

    private let generator = UINotificationFeedbackGenerator()

    func generateSuccessHaptic() {
        generator.notificationOccurred(.success)
    }

    func generateFailedHaptic() {
        generator.notificationOccurred(.error)
    }
}

// swiftlint:enable type_body_length function_body_length file_length
