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

    @State private var units = WeightUnit.mg
    @State private var perSprayText = ""
    @State private var perSpray: Double? = nil
    @State private var liquidAmountInMLText = ""
    @State private var liquidAmountInML: Double? = nil
    
    var sprayModels: [SprayModel] {
        []
    }
    @State private var selectedSpray: SprayModel? = nil
    @State private var isShowingAddSpray = false
    @State private var isShowingEditSpray = false

//    var mlPerSpray: Double? {
//        guard let numSprays else {return nil}
//        guard let liquidAmountInML else {return nil}
//        return liquidAmountInML/numSprays
//    }
//
//    var amountResult: Double? {
//        guard let perSpray else {return nil}
//        guard let numSprays else {return nil}
//        return perSpray * numSprays
//    }

    var body: some View {
        SprayCalculatorScreenContent(
            units: $units,
            perSprayText: $perSprayText,
            liquidAmountInMLText: $liquidAmountInMLText,
            sprayModels: [],
            selectedSpray: $selectedSpray,
            addSpray: {
                isShowingAddSpray.toggle()
            },
            editSprays: {
                isShowingEditSpray.toggle()
            }
        ).onChange(of: perSprayText) { newValue in
            perSpray = getDouble(from: newValue)
        }
        .onChange(of: liquidAmountInMLText) { newValue in
            liquidAmountInML = getDouble(from: newValue)
        }
        
    }
}

enum WeightUnit: String, CaseIterable {
    case mg, ug
}

struct SprayModel {
    let name: String
    let numSprays: Double
    let contentInMl: Double
}

struct SprayCalculatorScreenContent: View {

    @Binding var units: WeightUnit
    @Binding var perSprayText: String
    @Binding var liquidAmountInMLText: String
    let sprayModels: [SprayModel]
    @Binding var selectedSpray: SprayModel?
    let addSpray: () -> Void
    let editSprays: () -> Void

    var body: some View {
        List {
            Section("How much do you want per spray?") {
                HStack {
                    TextField("Per Spray", text: $perSprayText)
                        .keyboardType(.decimalPad)
                    Picker("Units", selection: $units) {
                        ForEach(WeightUnit.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }.labelsHidden()
                }
            }
            Section("How much liquid do you want to use?") {
                HStack {
                    TextField("Liquid Amount", text: $liquidAmountInMLText)
                        .keyboardType(.decimalPad)
                    Text("ml")
                }
            }
            Section {
                Button(action: addSpray) {
                    Label("Add Spray", systemImage: "plus")
                }
            } header: {
                HStack {
                    Text("Spray")
                    Spacer()
                    if !sprayModels.isEmpty {
                        Button("Edit Sprays", action: editSprays)
                    }
                }
            }
//            if let amountResult, liquidAmountInML != nil {
//                Section("Result") {
//                    Text("You need to put \(amountResult.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) \(units.rawValue) into \(liquidAmountInMLText) ml.").font(.title)
//                }
//            }
            
        }
        .navigationTitle("Spray Calculator")
    }
}

struct SprayCalculatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SprayCalculatorScreenContent(
                units: .constant(.mg),
                perSprayText: .constant(""),
                liquidAmountInMLText: .constant(""),
                sprayModels: [],
                selectedSpray: .constant(nil),
                addSpray: {},
                editSprays: {}
            ).headerProminence(.increased)
        }
    }
}
