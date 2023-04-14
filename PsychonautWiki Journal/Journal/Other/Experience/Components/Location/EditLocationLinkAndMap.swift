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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        HStack {
            Label(experienceLocation.nameUnwrapped, systemImage: "mappin")
            if let lat = experienceLocation.latitudeUnwrapped, let long = experienceLocation.longitudeUnwrapped {
                Spacer()
                Button {
                    openLocationInAppleMaps(latitude: lat, longitude: long, name: experienceLocation.nameUnwrapped)
                } label: {
                    let pinLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    Map(coordinateRegion: $region, interactionModes: [], annotationItems: [pinLocation]) {
                        MapMarker(coordinate: $0)
                    }
                    .onAppear {
                        region = MKCoordinateRegion(
                            center: pinLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                }
            }
        }
    }

    func openLocationInAppleMaps(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }

}
