//
//  LocationManager.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 09.01.23.
//

import Foundation
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    var currentLocation: Location?
    @Published var selectedLocation: Location? = nil
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
        locationFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \ExperienceLocation.experience?.creationDate, ascending: false) ]
        locationFetchRequest.fetchLimit = 15
        let sortedLocations = (try? PersistenceController.shared.viewContext.fetch(locationFetchRequest)) ?? []
        experienceLocations = sortedLocations.map( { loc in
            Location(name: loc.nameUnwrapped, longitude: loc.longitudeUnwrapped, latitude: loc.latitudeUnwrapped)
        }).unique
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            guard let foundCLLocation = locations.first else { return }
            let place = await getPlacemark(from: foundCLLocation)
            DispatchQueue.main.async {
                let locationName = place?.name ?? "Unknown"
                let location = Location(
                    name: locationName,
                    longitude: foundCLLocation.coordinate.longitude,
                    latitude: foundCLLocation.coordinate.latitude
                )
                self.currentLocation = location
                self.selectedLocation = location
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

    func searchLocations() {
        isSearchingForLocations = true
        Task {
            let geoCoder = CLGeocoder()
            do {
                let places = try await geoCoder.geocodeAddressString(searchText)
                DispatchQueue.main.async {
                    self.searchSuggestedLocations = places.map({ place in
                        Location(
                            name: place.name ?? "Unknown",
                            longitude: place.location?.coordinate.longitude,
                            latitude: place.location?.coordinate.latitude
                        )
                    })
                    self.isSearchingForLocations = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.searchSuggestedLocations = []
                    self.isSearchingForLocations = true
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

struct Location: Identifiable, Equatable {
    var id: String {
        name + (longitude?.description ?? "") + (latitude?.description ?? "")
    }
    let name: String
    let longitude: Double?
    let latitude: Double?
}

