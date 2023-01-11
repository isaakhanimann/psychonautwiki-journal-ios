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

import Foundation

extension ChooseDoseScreen {

    @MainActor
    class ViewModel: ObservableObject {
        @Published var selectedUnits: String? = UnitPickerOptions.mg.rawValue
        @Published var selectedPureDose: Double?
        @Published var purity = 100.0
        @Published var isEstimate = false
        @Published var isShowingNext = false

        private var impureDose: Double? {
            guard let selectedPureDose = selectedPureDose else { return nil }
            guard purity != 0 else { return nil }
            return selectedPureDose/purity * 100
        }
        var impureDoseRounded: Double? {
            guard let dose = impureDose else { return nil }
            return round(dose*10)/10
        }
        var impureDoseText: String {
            (impureDoseRounded?.formatted() ?? "..") + " " + (selectedUnits ?? "")
        }

        func initializeUnits(routeUnits: String?) {
            if let routeUnits = routeUnits {
                self.selectedUnits = routeUnits
            }
        }

    }
}
