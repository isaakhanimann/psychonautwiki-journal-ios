import Foundation
import CoreData
import CoreLocation

extension FinishIngestionScreen {

    @MainActor
    class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var enteredNote = ""
        @Published var enteredTitle = ""
        @Published var wantsToCreateNewExperience = false
        @Published var alreadyUsedColors = Set<SubstanceColor>()
        @Published var otherColors = Set<SubstanceColor>()
        @Published var notesInOrder = [String]()
        private var foundCompanion: SubstanceCompanion? = nil
        private var hasInitializedAlready = false
        @Published var experiencesWithinLargerRange: [Experience] = []
        @Published var selectedExperience: Experience?

        func initializeColorCompanionAndNote(for substanceName: String, suggestedNote: String?) {
            guard !hasInitializedAlready else {return} // because this function is going to be called again when navigating back from color picker screen
            if let suggestedNote {
                enteredNote = suggestedNote
            }
            let fetchRequest = SubstanceCompanion.fetchRequest()
            let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            alreadyUsedColors = Set(companions.map { $0.color })
            otherColors = Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
            let companionMatch = companions.first { comp in
                comp.substanceNameUnwrapped == substanceName
            }
            if let companionMatchUnwrap = companionMatch {
                foundCompanion = companionMatchUnwrap
                self.selectedColor = companionMatchUnwrap.color
            } else {
                self.selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
            }
            hasInitializedAlready = true
        }

        func addIngestion(
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool
        ) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let companion = createOrUpdateCompanion(with: context, substanceName: substanceName)
                if let existingExperience = selectedExperience, !wantsToCreateNewExperience {
                    createIngestion(
                        with: existingExperience,
                        and: context,
                        substanceName: substanceName,
                        administrationRoute: administrationRoute,
                        dose: dose,
                        units: units,
                        isEstimate: isEstimate,
                        substanceCompanion: companion
                    )
                    if #available(iOS 16.2, *) {
                        if existingExperience.isCurrent {
                            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: existingExperience.sortedIngestionsUnwrapped))
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
                    createIngestion(
                        with: newExperience,
                        and: context,
                        substanceName: substanceName,
                        administrationRoute: administrationRoute,
                        dose: dose,
                        units: units,
                        isEstimate: isEstimate,
                        substanceCompanion: companion
                    )
                    if #available(iOS 16.2, *) {
                        if newExperience.isCurrent {
                            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: newExperience.sortedIngestionsUnwrapped))
                        }
                    }
                }
                try? context.save()
            }
        }


        private func createOrUpdateCompanion(with context: NSManagedObjectContext, substanceName: String) -> SubstanceCompanion {
            if let foundCompanion {
                foundCompanion.colorAsText = selectedColor.rawValue
                return foundCompanion
            } else {
                let companion = SubstanceCompanion(context: context)
                companion.substanceName = substanceName
                companion.colorAsText = selectedColor.rawValue
                return companion
            }
        }

        private func createIngestion(
            with experience: Experience,
            and context: NSManagedObjectContext,
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool,
            substanceCompanion: SubstanceCompanion
        ) {
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.creationDate = Date()
            ingestion.dose = dose ?? 0
            ingestion.units = units
            ingestion.isEstimate = isEstimate
            ingestion.note = enteredNote
            ingestion.administrationRoute = administrationRoute.rawValue
            ingestion.substanceName = substanceName
            ingestion.color = selectedColor.rawValue
            ingestion.experience = experience
            ingestion.substanceCompanion = substanceCompanion
        }

        override init() {
            super.init()
            manager.delegate = self
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.predicate = NSPredicate(format: "note.length > 0")
            ingestionFetchRequest.fetchLimit = 15
            let sortedIngestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
            notesInOrder = sortedIngestions.map { ing in
                ing.noteUnwrapped
            }.uniqued()
            $selectedTime.map({ date in
                let fetchRequest = Experience.fetchRequest()
                fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false) ]
                fetchRequest.predicate = FinishIngestionScreen.ViewModel.getPredicate(from: date)
                return (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            }).assign(to: &$experiencesWithinLargerRange)
            $selectedTime.combineLatest($experiencesWithinLargerRange) { date, experiences in
                FinishIngestionScreen.ViewModel.getExperienceClosest(from: experiences, date: date)
            }.assign(to: &$selectedExperience)
        }

        private static func getExperienceClosest(from experiences: [Experience], date: Date) -> Experience? {
            let halfDay: TimeInterval = 12*60*60
            let startDate = date.addingTimeInterval(-halfDay)
            let endDate = date.addingTimeInterval(halfDay)
            return experiences.first { exp in
                startDate < exp.sortDateUnwrapped && exp.sortDateUnwrapped < endDate
            }
        }

        private static func getPredicate(from date: Date) -> NSCompoundPredicate {
            let twoDays: TimeInterval = 48*60*60
            let startDate = date.addingTimeInterval(-twoDays)
            let endDate = date.addingTimeInterval(twoDays)
            let laterThanStart = NSPredicate(format: "sortDate > %@", startDate as NSDate)
            let earlierThanEnd = NSPredicate(format: "sortDate < %@", endDate as NSDate)
            return NSCompoundPredicate(
                andPredicateWithSubpredicates: [laterThanStart, earlierThanEnd]
            )
        }

        let manager = CLLocationManager()

        var currentLocation: CLLocationCoordinate2D?
        @Published var selectedLocation: Location? = nil
        @Published var authorizationStatus: CLAuthorizationStatus?
        @Published var searchSuggestedLocations: [Location] = []
        @Published var selectedLocationName = ""


        func requestLocation() {
            manager.requestLocation()
        }

        func requestPermission() {
            manager.requestWhenInUseAuthorization()
        }

        nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            Task {
                guard let foundLocation = locations.first else { return }
                let place = await getPlacemark(from: foundLocation)
                DispatchQueue.main.async {
                    self.currentLocation = foundLocation.coordinate
                    let locationName = place?.locality ?? "Unknown"
                    self.selectedLocation = Location(
                        name: locationName,
                        longitude: foundLocation.coordinate.longitude,
                        latitude: foundLocation.coordinate.latitude
                    )
                    self.selectedLocationName = locationName
                }
            }
        }

        nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            assertionFailure("Isaak location manager \(error)")
        }

        nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            DispatchQueue.main.async {
                self.authorizationStatus = manager.authorizationStatus
                if manager.authorizationStatus == .authorizedWhenInUse {
                    manager.requestLocation()
                }
            }
        }

        func selectLocation(location: Location) {
            selectedLocation = location
            selectedLocationName = location.name
        }

        func searchLocations(with query: String) {
            Task {
                let geoCoder = CLGeocoder()
                do {
                    let places = try await geoCoder.geocodeAddressString(query)
                    DispatchQueue.main.async {
                        self.searchSuggestedLocations = places.map({ place in
                            Location(
                                name: place.locality ?? "Unknown",
                                longitude: place.location?.coordinate.longitude,
                                latitude: place.location?.coordinate.latitude
                            )
                        })
                    }
                } catch {
                    assertionFailure("Failed to find location: \(error)")
                    DispatchQueue.main.async {
                        self.searchSuggestedLocations = []
                    }
                }
            }
        }

        private func getPlacemark(from location: CLLocation) async -> CLPlacemark? {
            let geocoder = CLGeocoder()
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                return placemarks.first
            } catch {
                assertionFailure("Failed to get placemark: \(error)")
                return nil
            }
        }
    }
}

struct Location: Identifiable {
    var id: String {
        name + (longitude?.description ?? "") + (latitude?.description ?? "")
    }
    let name: String
    let longitude: Double?
    let latitude: Double?
}
