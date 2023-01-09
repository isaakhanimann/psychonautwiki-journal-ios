//
//  ChooseLocationScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.01.23.
//

import SwiftUI
import CoreLocation
import MapKit

struct ChooseLocationScreen: View {

    @ObservedObject var locationManager: LocationManager

    var body: some View {
        ChooseLocationScreenContent(
            selectedLocation: $locationManager.selectedLocation,
            selectedLocationName: $locationManager.selectedLocationName,
            searchText: $locationManager.searchText,
            authorizationStatus: locationManager.authorizationStatus,
            isLoadingLocationResults: locationManager.isSearchingForLocations,
            currentLocation: locationManager.currentLocation,
            searchSuggestedLocations: locationManager.searchSuggestedLocations
        )
        .searchable(text: $locationManager.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Location")
        .onSubmit(of: .search) {
            locationManager.searchLocations()
        }
        .task {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestPermission()
            }
        }
    }
}

struct ChooseLocationScreenContent: View {

    @Binding var selectedLocation: Location?
    @Binding var selectedLocationName: String
    @Binding var searchText: String
    let authorizationStatus: CLAuthorizationStatus?
    let isLoadingLocationResults: Bool
    let currentLocation: Location?
    let searchSuggestedLocations: [Location]
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        List {
            if isSearching {
                if let currentLocation {
                    Button {
                        selectedLocation = currentLocation
                        selectedLocationName = currentLocation.name
                        dismissSearch()
                    } label: {
                        Label("Current Location", systemImage: "location")
                    }
                }
                if isLoadingLocationResults {
                    ProgressView()
                } else if !searchSuggestedLocations.isEmpty {
                    ForEach(searchSuggestedLocations) { location in
                        Button {
                            selectedLocation = location
                            selectedLocationName = location.name
                            dismissSearch()
                        } label: {
                            Label(location.name, systemImage: "location")
                        }
                    }
                }
            } else {
                Section("Selected Location") {
                    TextField("Name", text: $selectedLocationName, prompt: Text("Enter Name"))
                        .onChange(of: selectedLocationName) { name in
                            selectedLocation = Location(
                                name: name,
                                longitude: selectedLocation?.longitude,
                                latitude: selectedLocation?.latitude
                            )
                        }
                    if let lat = selectedLocation?.latitude, let long = selectedLocation?.longitude {
                        ZStack(alignment: .topTrailing) {
                            Map(
                                coordinateRegion: .constant(
                                    MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: lat, longitude: long),
                                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                    )
                                ),
                                interactionModes: []
                            )
                            .frame(height: 200)
                            .cornerRadius(10)
                            Button {
                                selectedLocation = Location(name: selectedLocationName, longitude: nil, latitude: nil)
                            } label: {
                                Label("Delete Coordinates", systemImage: "x.circle").labelStyle(.iconOnly)
                            }

                        }
                    }
                }
            }
            if authorizationStatus != .authorizedWhenInUse {
                Section {
                    Text("The app does not have access to your location. Enable it in settings to add locations to your experiences automatically.")
                }
            }
        }
        .navigationTitle("Experience Location")
    }
}

struct ChooseLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseLocationScreenContent(
                selectedLocation: .constant(
                    Location(name: "Zurich", longitude: 2, latitude: 2)
                ),
                selectedLocationName: .constant(""),
                searchText: .constant(""),
                authorizationStatus: .denied,
                isLoadingLocationResults: false,
                currentLocation: nil,
                searchSuggestedLocations: [
                    Location(name: "Zurich", longitude: 2, latitude: 2),
                    Location(name: "Madrid", longitude: 2, latitude: 2),
                    Location(name: "Prag", longitude: 2, latitude: 2)
                ]
            )
        }
    }
}
