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

import SwiftUI

struct AddLocationScreen: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var experience: Experience

    var body: some View {
        ChooseLocationScreen(
            locationManager: locationManager,
            onDone: onDone
        )
        .onAppear {
            locationManager.selectedLocation = nil
            locationManager.selectedLocationName = ""
        }
    }

    private func onDone() {
        if let selectedLocation = locationManager.selectedLocation {
            let newLocation = ExperienceLocation(context: PersistenceController.shared.viewContext)
            newLocation.name = selectedLocation.name
            newLocation.latitude = selectedLocation.latitude ?? 0
            newLocation.longitude = selectedLocation.longitude ?? 0
            newLocation.experience = experience
            PersistenceController.shared.saveViewContext()
        }
    }
}
