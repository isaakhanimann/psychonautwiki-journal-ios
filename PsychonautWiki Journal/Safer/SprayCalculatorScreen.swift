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

struct SprayCalculatorScreen: View {

    enum WeightUnit: String, CaseIterable {
        case mg, ug
    }

    @State private var units = WeightUnit.mg
    @State private var perSprayText = ""
    @State private var perSpray: Double? = nil
    @State private var liquidAmountInMLText = ""
    @State private var liquidAmountInML: Double? = nil
    @State private var numSpraysText = ""
    @State private var numSprays: Double? = nil

    var mlPerSpray: Double? {
        guard let numSprays else {return nil}
        guard let liquidAmountInML else {return nil}
        return liquidAmountInML/numSprays
    }

    var amountResult: Double? {
        guard let perSpray else {return nil}
        guard let numSprays else {return nil}
        return perSpray * numSprays
    }

    var body: some View {
        List {
            Section("How much do you want per spray?") {
                Picker("Units", selection: $units) {
                    ForEach(WeightUnit.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                TextField("Per Spray", text: $perSprayText)
                    .keyboardType(.decimalPad)
                    .onChange(of: perSprayText) { newValue in
                        perSpray = getDouble(from: newValue)
                    }
            }
            Section("How much liquid do you want to use?") {
                HStack {
                    TextField("Liquid Amount", text: $liquidAmountInMLText)
                        .keyboardType(.decimalPad)
                        .onChange(of: liquidAmountInMLText) { newValue in
                            liquidAmountInML = getDouble(from: newValue)
                        }
                    Text("ml")
                }
            }
            Section {
                TextField("Number of sprays", text: $numSpraysText)
                    .keyboardType(.decimalPad)
                    .onChange(of: numSpraysText) { newValue in
                        numSprays = getDouble(from: newValue)
                    }
                if let mlPerSpray {
                    Text("\(mlPerSpray.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) ml/spray")
                }
            } header: {
                Text("How many sprays are in \(liquidAmountInML == nil ? "..." : liquidAmountInMLText) ml?")
            } footer: {
                Text("Note: fill it into the spray bottle and count the number of sprays. Its recommended to have small spray bottles (5ml) and fill it completely so the last couple of sprays still work.")
            }
            if let amountResult, liquidAmountInML != nil {
                Section("Result") {
                    Text("You need to put \(amountResult.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) \(units.rawValue) into \(liquidAmountInMLText) ml.").font(.title)
                }
            }
            Section {
                Text("""
Its better to use nose spray than to snort powder because it damages the nasal mucous less. To not damage the nasal mucous and have a similar short onset and effectiveness of insufflation use rectal administration (link).
However substances are the most stable in their crystaline form and degrade more quickly if dissolved in liquid, which might be relevant to you if you plan on storing it for months or years.
""")
            }
        }.navigationTitle("Spray Calculator")
    }
}

struct SprayCalculatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SprayCalculatorScreen().headerProminence(.increased)
        }
    }
}
