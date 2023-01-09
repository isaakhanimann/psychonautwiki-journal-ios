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
    var deleteAssociatedLocation: (() -> Void)? = nil

    var body: some View {
        ChooseLocationScreenContent(
            selectedLocation: $locationManager.selectedLocation,
            selectedLocationName: $locationManager.selectedLocationName,
            searchText: $locationManager.searchText,
            authorizationStatus: locationManager.authorizationStatus,
            isLoadingLocationResults: locationManager.isSearchingForLocations,
            currentLocation: locationManager.currentLocation,
            searchSuggestedLocations: locationManager.searchSuggestedLocations,
            experienceLocations: locationManager.experienceLocations,
            deleteAssociatedLocation: deleteAssociatedLocation
        )
        .searchable(
            text: $locationManager.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search Location"
        )
        .disableAutocorrection(true)
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
    let experienceLocations: [Location]
    var deleteAssociatedLocation: (() -> Void)?
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.dismiss) var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )


    var body: some View {
        List {
            if isSearching {
                if isLoadingLocationResults {
                    ProgressView()
                } else if !searchSuggestedLocations.isEmpty {
                    ForEach(searchSuggestedLocations) { location in
                        Button {
                            withAnimation {
                                selectedLocation = location
                                selectedLocationName = location.name
                                dismissSearch()
                            }
                        } label: {
                            Label(location.name, systemImage: "location")
                        }
                    }
                }
            } else {
                Section("Selected Location") {
                    TextField("Name", text: $selectedLocationName, prompt: Text("Enter Name"))
                        .onChange(of: selectedLocationName) { name in
                            withAnimation {
                                selectedLocation = Location(
                                    name: name,
                                    longitude: selectedLocation?.longitude,
                                    latitude: selectedLocation?.latitude
                                )
                            }
                        }
                    if let lat = selectedLocation?.latitude, let long = selectedLocation?.longitude {
                        let pinLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        ZStack(alignment: .topTrailing) {
                            Map(coordinateRegion: $region, annotationItems: [pinLocation]) {
                                MapMarker(coordinate: $0)
                            }
                            .onAppear {
                                region = MKCoordinateRegion(
                                    center: pinLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                )
                            }
                            .frame(height: 200)
                            Button {
                                withAnimation {
                                    selectedLocation = Location(name: selectedLocationName, longitude: nil, latitude: nil)
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(.systemGray5))
                                        .frame(width: 25)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .contentShape(Circle())
                            }
                            .accessibilityLabel(Text("Delete Coordinates"))
                        }
                        .listRowInsets(EdgeInsets())

                    }
                }
            }
            if !experienceLocations.isEmpty {
                Section("Suggestions") {
                    if let currentLocation {
                        Button {
                            withAnimation {
                                selectedLocation = currentLocation
                                selectedLocationName = currentLocation.name
                                dismissSearch()
                            }
                        } label: {
                            Label("Current Location", systemImage: "location")
                        }
                    }
                    ForEach(experienceLocations) { location in
                        Button {
                            withAnimation {
                                selectedLocation = location
                                selectedLocationName = location.name
                            }
                        } label: {
                            Label(location.name, systemImage: "clock.arrow.circlepath")
                        }
                    }
                }
            }
            if authorizationStatus != .authorizedWhenInUse {
                Section {
                    Text("The app does not have access to your location. Enable it in settings to add locations to your experiences automatically.")
                }
            }
            if let deleteAssociatedLocation {
                Section {
                    Button {
                        // must delete first and dismiss after because else the deletion might be cancelled
                        deleteAssociatedLocation()
                        dismiss()
                    } label: {
                        Label("Delete Location", systemImage: "trash").foregroundColor(.red)
                    }

                }
            }
        }
        .navigationTitle("Experience Location")
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
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
                    Location(name: "Street Name 1", longitude: 2, latitude: 2),
                    Location(name: "Street Name 2", longitude: 2, latitude: 2),
                    Location(name: "Street Name 3", longitude: 2, latitude: 2)
                ],
                experienceLocations: [
                    Location(name: "Home", longitude: 2, latitude: 2),
                    Location(name: "Festival", longitude: 2, latitude: 2)
                ],
                deleteAssociatedLocation: {}
            )
        }
    }
}
