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

struct VolumetricDosingScreen: View {
    var body: some View {
        List {
            Text(
                """
                Volumetric dosing is the process of dissolving a compound in a liquid to make it easier to measure. In the interest of harm reduction, it is important to use volumetric dosing with certain compounds that are too potent to measure with traditional weighing scales.
                Many psychoactive substances, including benzodiazepines and certain psychedelics, are active at less than a single milligram. Such small quantities cannot be accurately measured with common digital scales, so the substance must instead be dosed volumetrically by weighing out larger amounts of the compound and dissolving it in a calculated volume of a suitable liquid.

                Search the internet to determine what solvent to use. All substances should dissolve in alcohol, but many substances will not dissolve in water.
                """)
        }
        .navigationTitle("Volumetric Dosing")
    }
}

#Preview {
    NavigationStack {
        VolumetricDosingScreen()
    }
}
