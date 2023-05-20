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
            perSpray: $viewModel.weightPerSprayText,
            liquidAmountInMl: $viewModel.liquidAmountInMlText,
            totalWeight: $viewModel.totalWeightText,
            purityInPercent: $viewModel.purityInPercentText,
            sprayModels: viewModel.sprayModels,
            selectedSpray: $viewModel.selectedSpray,
            addSpray: {
                viewModel.isShowingAddSpray.toggle()
            },
            deleteSprays: viewModel.deleteSprays
        )
        .sheet(isPresented: $viewModel.isShowingAddSpray) {
            AddSprayScreen()
        }
        .onDisappear {
            viewModel.saveSelect()
        }
    }
}

struct SprayCalculatorScreenContent: View {

    @Binding var units: WeightUnit
    @Binding var perSpray: String
    @Binding var liquidAmountInMl: String
    @Binding var totalWeight: String
    @Binding var purityInPercent: String
    let sprayModels: [SprayModel]
    @Binding var selectedSpray: SprayModel?
    let addSpray: () -> Void
    let deleteSprays: (IndexSet) -> Void
    @Environment(\.editMode) private var editMode
    @Environment(\.colorScheme) var colorScheme

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
                ForEach(sprayModels) { model in
                    Button {
                        selectedSpray = model
                    } label: {
                        HStack {
                            Text(model.name).font(.headline).foregroundColor(colorScheme == .dark ? Color.white : .black)
                            Text("\(model.contentInMl.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) ml = \(model.numSprays.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 2)) sprays").foregroundColor(.secondary)
                            Spacer()
                            if selectedSpray == model {
                                Image(systemName: "checkmark").font(.headline).foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteSprays)
                if editMode?.wrappedValue.isEditing == true || sprayModels.isEmpty {
                    addSprayButton
                }

            } header: {
                HStack {
                    Text("Spray Size")
                    Spacer()
                    if !sprayModels.isEmpty {
                        EditButton()
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
                            TextField("Substance", text: $totalWeight)
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

    private var addSprayButton: some View {
        Button(action: addSpray) {
            Label("Add Spray", systemImage: "plus")
        }
    }
}

struct SprayCalculatorScreen_Previews: PreviewProvider {

    static var previews: some View {
        let sprays = [
            SprayModel(name: "Small Spray", numSprays: 32, contentInMl: 5, spray: nil),
            SprayModel(name: "Big Spray", numSprays: 50, contentInMl: 10, spray: nil)
        ]
        NavigationView {
            SprayCalculatorScreenContent(
                units: .constant(.mg),
                perSpray: .constant(""),
                liquidAmountInMl: .constant(""),
                totalWeight: .constant(""),
                purityInPercent: .constant("90"),
                sprayModels: sprays,
                selectedSpray: .constant(sprays.first),
                addSpray: {},
                deleteSprays: {_ in }
            ).headerProminence(.increased)
        }
    }
}
