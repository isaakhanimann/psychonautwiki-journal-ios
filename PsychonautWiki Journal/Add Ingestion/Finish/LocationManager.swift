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

import CoreLocation
import Foundation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var currentLocation: Location?
    @Published var selectedLocation: Location?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var searchSuggestedLocations: [Location] = []
    @Published var selectedLocationName = ""
    @Published var isSearchingForLocations = false
    @Published var searchText = ""
    @Published var experienceLocations: [Location] = []

    override init() {
        super.init()
        manager.delegate = self
        let locationFetchRequest = ExperienceLocation.fetchRequest()
        locationFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExperienceLocation.experience?.creationDate, ascending: false)]
        locationFetchRequest.fetchLimit = 15
        let sortedLocations = (try? PersistenceController.shared.viewContext.fetch(locationFetchRequest)) ?? []
        experienceLocations = sortedLocations.map { loc in
            Location(name: loc.nameUnwrapped, longitude: loc.longitudeUnwrapped, latitude: loc.latitudeUnwrapped)
        }.unique
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func maybeRequestLocation() {
        if authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            guard let foundCLLocation = locations.last else { return }
            let place = await getPlacemark(from: foundCLLocation)
            Task { @MainActor in
                let locationName = place?.subLocality ?? place?.name ?? "Unknown"
                let location = Location(
                    name: locationName,
                    longitude: foundCLLocation.coordinate.longitude,
                    latitude: foundCLLocation.coordinate.latitude
                )
                self.currentLocation = location
                if self.shouldUpdateSelectedLocation {
                    self.selectLocation(location: location)
                    self.shouldUpdateSelectedLocation = false
                }
            }
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Isaak location manager \(error)") // no assertion failure because this is triggered when adding an ingestion with app intent
    }

    private var shouldUpdateSelectedLocation = false

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let before = self.authorizationStatus
            let after = manager.authorizationStatus
            let didJustNowGivePermission = before == CLAuthorizationStatus.notDetermined && after == .authorizedWhenInUse
            if didJustNowGivePermission {
                manager.requestLocation()
                self.shouldUpdateSelectedLocation = true
            }
            self.authorizationStatus = after
        }
    }

    func selectLocation(location: Location) {
        selectedLocation = location
        selectedLocationName = location.name
    }

    func searchLocations() {
        isSearchingForLocations = true
        Task {
            let geoCoder = CLGeocoder()
            var foundLocations: [Location] = []
            if let places = try? await geoCoder.geocodeAddressString(searchText) {
                foundLocations = places.map { place in
                    Location(
                        name: place.name ?? "Unknown",
                        longitude: place.location?.coordinate.longitude,
                        latitude: place.location?.coordinate.latitude
                    )
                }
            }
            Task { @MainActor in
                self.searchSuggestedLocations = foundLocations
                self.isSearchingForLocations = false
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

struct Location: Identifiable, Equatable {
    var id: String {
        name
    }

    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }

    let name: String
    let longitude: Double?
    let latitude: Double?
}
