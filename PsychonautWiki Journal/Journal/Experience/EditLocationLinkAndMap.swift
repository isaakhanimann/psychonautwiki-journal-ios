//
//  LocationSection.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 09.01.23.
//

import SwiftUI
import MapKit

struct EditLocationLinkAndMap: View {

    @ObservedObject var experienceLocation: ExperienceLocation
    @ObservedObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
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
                        experienceLocation.name = locationManager.selectedLocation?.name
                        experienceLocation.latitude = locationManager.selectedLocation?.latitude ?? 0
                        experienceLocation.longitude = locationManager.selectedLocation?.longitude ?? 0
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
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                }
                .frame(height: 200)
                .listRowInsets(EdgeInsets())
            }
        
    }
}
