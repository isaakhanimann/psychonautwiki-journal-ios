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

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        SprayCalculatorScreenContent(
            units: $viewModel.units,
            perSpray: $viewModel.perSprayText,
            liquidAmountInMl: $viewModel.liquidAmountInMlText,
            purityInPercent: $viewModel.purityInPercentText,
            sprayModels: viewModel.sprayModels,
            selectedSpray: $viewModel.selectedSpray,
            addSpray: {
                viewModel.isShowingAddSpray.toggle()
            },
            editSprays: {
                viewModel.isShowingEditSpray.toggle()
            }
        ).onChange(of: viewModel.perSprayText) { newValue in
            viewModel.perSpray = getDouble(from: newValue)
        }.onChange(of: viewModel.liquidAmountInMlText) { newValue in
            viewModel.liquidAmountInMl = getDouble(from: newValue)
        }.onChange(of: viewModel.purityInPercentText) { newValue in
            viewModel.purityInPercent = getDouble(from: newValue)
        }
        .sheet(isPresented: $viewModel.isShowingAddSpray) {
            AddSprayScreen()
        }
    }
}

struct SprayCalculatorScreenContent: View {

    @Binding var units: WeightUnit
    @Binding var perSpray: String
    @Binding var liquidAmountInMl: String
    @Binding var purityInPercent: String
    let sprayModels: [SprayModel]
    @Binding var selectedSpray: SprayModel?
    let addSpray: () -> Void
    let editSprays: () -> Void

    var body: some View {
        List {
            Section("How much do you want per spray?") {
                HStack {
                    TextField("Per Spray", text: $perSpray)
                        .keyboardType(.decimalPad)
                    Picker("Units", selection: $units) {
                        ForEach(WeightUnit.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }.labelsHidden()
                }
            }
            Section {
                Button(action: addSpray) {
                    Label("Add Spray", systemImage: "plus")
                }
            } header: {
                HStack {
                    Text("Spray Size")
                    Spacer()
                    if !sprayModels.isEmpty {
                        Button("Edit Sprays", action: editSprays)
                    }
                }
            }
            Section("Result") {
                HStack(alignment: .top) {
                    TextField("Liquid", text: $liquidAmountInMl)
                        .keyboardType(.decimalPad)
                    Text("ml")
                    Image(systemName: "arrow.left.arrow.right")
                    VStack {
                        HStack {
                            TextField("Substance", text: $liquidAmountInMl)
                                .keyboardType(.decimalPad)
                            Text(units.rawValue)
                        }
                        HStack {
                            TextField("Purity", text: $purityInPercent)
                                .keyboardType(.decimalPad)
                            Text("%")
                        }
                    }
                }
            }
//            if let amountResult, liquidAmountInML != nil {
//                Section("Result") {
//                    Text("You need to put \(amountResult.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) \(units.rawValue) into \(liquidAmountInMLText) ml.").font(.title)
//                }
//            }
            Section {
                Text("""
Volumetric dosing substances.
Its better to use nose spray than to snort powder because it damages the nasal mucous less. To not damage the nasal mucous and have a similar short onset and effectiveness of insufflation use rectal administration (link).
However substances are the most stable in their crystaline form and degrade more quickly if dissolved in liquid, which might be relevant to you if you plan on storing it for months or years.
""")
            }
        }
        .navigationTitle("Spray Calculator")
    }
}

struct SprayCalculatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SprayCalculatorScreenContent(
                units: .constant(.mg),
                perSpray: .constant(""),
                liquidAmountInMl: .constant(""),
                purityInPercent: .constant("90"),
                sprayModels: [],
                selectedSpray: .constant(nil),
                addSpray: {},
                editSprays: {}
            ).headerProminence(.increased)
        }
    }
}
