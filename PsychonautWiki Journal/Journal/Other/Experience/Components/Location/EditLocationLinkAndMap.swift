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

import MapKit
import SwiftUI

struct EditLocationLinkAndMap: View {
    @ObservedObject var experienceLocation: ExperienceLocation

    var body: some View {
        Label(experienceLocation.nameUnwrapped, systemImage: "mappin")
        if let lat = experienceLocation.latitudeUnwrapped, let long = experienceLocation.longitudeUnwrapped {
            Button {
                openLocationInAppleMaps(latitude: lat, longitude: long, name: experienceLocation.nameUnwrapped)
            } label: {
                MapWithPinView(latitude: lat, longitude: long)
                    .frame(height: 150)
                    .allowsHitTesting(false)
            }
            .listRowInsets(EdgeInsets())
        }
    }

    func openLocationInAppleMaps(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps()
    }
}

struct MapWithPinView: View {
    @State private var region: MKCoordinateRegion
    let pinCoordinate: CLLocationCoordinate2D

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _region = State(initialValue: MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        pinCoordinate = coordinate
    }

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: [], annotationItems: [pinCoordinate]) {
            MapMarker(coordinate: $0)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
