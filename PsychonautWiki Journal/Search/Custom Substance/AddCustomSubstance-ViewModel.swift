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

extension AddCustomSubstanceView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var name = ""
        @Published var explanation = ""
        @Published var units: String = UnitPickerOptions.mg.rawValue

        var isEverythingNeededDefined: Bool {
            guard !name.isEmpty else { return false }
            guard !units.isEmpty else { return false }
            return true
        }

        func saveCustom(onComplete: (() -> Void)) {
            assert(isEverythingNeededDefined, "Tried to save custom substance without defining the necessary fields")
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let custom = CustomSubstance(context: context)
                custom.name = name
                custom.units = units
                if explanation.isEmpty {
                    custom.explanation = nil
                } else {
                    custom.explanation = explanation
                }
                try? context.save()
                onComplete()
            }
        }
    }
}
