// Copyright (c) 2023. Isaak Hanimann.
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
import MapKit
import SwiftUI

struct ChooseLocationScreenContent: View {
    @Binding var selectedLocation: Location?
    @Binding var selectedLocationName: String
    @Binding var searchText: String
    let authorizationStatus: CLAuthorizationStatus?
    let isLoadingLocationResults: Bool
    let currentLocation: Location?
    let searchSuggestedLocations: [Location]
    let experienceLocations: [Location]
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        List {
            if isSearching {
                if isLoadingLocationResults {
                    ProgressView()
                } else {
                    Section {
                        if searchSuggestedLocations.isEmpty {
                            Text("No Results")
                        } else {
                            ForEach(searchSuggestedLocations) { location in
                                Button {
                                    withAnimation {
                                        selectedLocation = location
                                        selectedLocationName = location.name
                                        dismissSearch()
                                    }
                                } label: {
                                    Label(location.name, systemImage: "mappin")
                                }
                            }
                        }
                    }
                }
            } else {
                Section("Selected Location") {
                    TextField("Name", text: $selectedLocationName, prompt: Text("Enter Name"))
                        .onChange(of: selectedLocationName) { name in
                            withAnimation {
                                if !name.isEmpty {
                                    selectedLocation = Location(
                                        name: name,
                                        longitude: selectedLocation?.longitude,
                                        latitude: selectedLocation?.latitude
                                    )
                                }
                            }
                        }
                    if let lat = selectedLocation?.latitude, let long = selectedLocation?.longitude {
                        let pinLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        ZStack(alignment: .topTrailing) {
                            Map(coordinateRegion: $region, annotationItems: [pinLocation]) {
                                MapMarker(coordinate: $0)
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                    withAnimation {
                                        region = MKCoordinateRegion(
                                            center: pinLocation,
                                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                        )
                                    }
                                }
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
                    if selectedLocation != nil {
                        Button {
                            selectedLocationName = ""
                            selectedLocation = nil
                        } label: {
                            Label("Delete Location", systemImage: "trash").foregroundColor(.red)
                        }
                    }
                }
                if !experienceLocations.isEmpty || currentLocation != nil {
                    Section("Suggestions") {
                        if let currentLocation {
                            Button {
                                withAnimation {
                                    selectedLocation = currentLocation
                                    selectedLocationName = currentLocation.name
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
            }
            if authorizationStatus != .authorizedWhenInUse {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Section {
                        Button {
                            Task {
                                await UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Enable Location Access", systemImage: "gearshape")
                        }
                    } footer: {
                        Text("Enable location access in settings to add locations to your experiences automatically.")
                    }
                }
            }
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

#Preview {
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
            Location(name: "Street Name 3", longitude: 2, latitude: 2),
        ],
        experienceLocations: [
            Location(name: "Home", longitude: 2, latitude: 2),
            Location(name: "Festival", longitude: 2, latitude: 2),
        ]
    )
}
