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

    @ObservedObject var viewModel: FinishIngestionScreen.ViewModel

    var body: some View {
        ChooseLocationScreenContent(
            selectedLocation: $viewModel.selectedLocation,
            selectedLocationName: $viewModel.selectedLocationName,
            authorizationStatus: viewModel.authorizationStatus,
            isSearchingForLocations: viewModel.isSearchingForLocations,
            searchSuggestedLocations: viewModel.searchSuggestedLocations,
            searchLocations: { query in
                viewModel.searchLocations(with: query)
            }
        )
        .task {
            if viewModel.authorizationStatus == .notDetermined {
                viewModel.requestPermission()
            }
        }
    }
}

struct ChooseLocationScreenContent: View {

    @Binding var selectedLocation: Location?
    @Binding var selectedLocationName: String
    let authorizationStatus: CLAuthorizationStatus?
    let isSearchingForLocations: Bool
    let searchSuggestedLocations: [Location]
    let searchLocations: (String) -> Void
    @State private var searchText = ""

    var body: some View {
        List {
            if isSearchingForLocations {
                ProgressView()
            } else if !searchSuggestedLocations.isEmpty {
                Section {
                    ForEach(searchSuggestedLocations) { location in
                        Button {
                            selectedLocation = location
                            selectedLocationName = location.name
                        } label: {
                            Label(location.name, systemImage: "location")
                        }
                    }
                }
            }
            if let status = authorizationStatus {
                if status == .notDetermined {
                    Text("not determined")
                }
                if status == .authorizedWhenInUse {
                    Text("authorizedwheninuse")
                }
                if status == .denied {
                    Text("denied")
                }
                if status == .restricted {
                    Text("restricted")
                }
            }
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
                }
            }
            if authorizationStatus != .authorizedWhenInUse {
                Section {
                    Text("The app does not have access to your location. Enable it in settings so you can add coordinates to your experiences.")
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            searchLocations(searchText)
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
                authorizationStatus: .denied,
                isSearchingForLocations: false,
                searchSuggestedLocations: [
                    Location(name: "Zurich", longitude: 2, latitude: 2),
                    Location(name: "Madrid", longitude: 2, latitude: 2),
                    Location(name: "Prag", longitude: 2, latitude: 2)
                ],
                searchLocations: {_ in }
            )
        }
    }
}
