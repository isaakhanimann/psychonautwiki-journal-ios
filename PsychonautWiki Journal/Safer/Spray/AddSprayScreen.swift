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

struct AddSprayScreen: View {

    @State private var numSpraysText = ""
    @State private var numSprays: Double? = nil
    
    var body: some View {
        List {
            Text("Note: fill it into the spray bottle and count the number of sprays. Its recommended to have small spray bottles (5ml) and fill it completely so the last couple of sprays still work.")
            TextField("Number of sprays", text: $numSpraysText)
                .keyboardType(.decimalPad)
            Section {
                Text("""
Its better to use nose spray than to snort powder because it damages the nasal mucous less. To not damage the nasal mucous and have a similar short onset and effectiveness of insufflation use rectal administration (link).
However substances are the most stable in their crystaline form and degrade more quickly if dissolved in liquid, which might be relevant to you if you plan on storing it for months or years.
""")
            }

        }
        .onChange(of: numSpraysText) { newValue in
            numSprays = getDouble(from: newValue)
        }
    }
}

struct AddSprayScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddSprayScreen()
    }
}
