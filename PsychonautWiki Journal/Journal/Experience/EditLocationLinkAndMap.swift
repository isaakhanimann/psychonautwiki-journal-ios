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
import MapKit

struct EditLocationLinkAndMap: View {

    @ObservedObject var experienceLocation: ExperienceLocation
    @ObservedObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    )

    var body: some View {
        NavigationLink {
            ChooseLocationScreen(locationManager: locationManager)
            .onAppear {
                locationManager.selectedLocation = Location(
                    name: experienceLocation.nameUnwrapped,
                    longitude: experienceLocation.longitudeUnwrapped,
                    latitude: experienceLocation.latitudeUnwrapped
                )
                locationManager.selectedLocationName = experienceLocation.nameUnwrapped
            }
            .onDisappear {
                if let selectedLocation = locationManager.selectedLocation {
                    experienceLocation.name = selectedLocation.name
                    experienceLocation.latitude = selectedLocation.latitude ?? 0
                    experienceLocation.longitude = selectedLocation.longitude ?? 0
                } else {
                    PersistenceController.shared.viewContext.delete(experienceLocation)
                }
                PersistenceController.shared.saveViewContext()
            }
        } label: {
            Label(experienceLocation.nameUnwrapped, systemImage: "location")
        }
        if let lat = experienceLocation.latitudeUnwrapped, let long = experienceLocation.longitudeUnwrapped {
            let pinLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            Map(coordinateRegion: $region, annotationItems: [pinLocation]) {
                MapMarker(coordinate: $0)
            }
            .onAppear {
                region = MKCoordinateRegion(
                    center: pinLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
                )
            }
            .frame(height: 300)
            .listRowInsets(EdgeInsets())
        }
        
    }
}
