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

struct UnitsPicker: View {
    @Binding var units: String
    @State private var pickerValue = UnitPickerOptions.mg
    @State private var textValue = ""

    var body: some View {
        Group {
            Picker("Units", selection: $pickerValue) {
                ForEach(UnitPickerOptions.allCases, id: \.self) { unit in
                    Text(unit.rawValue)
                        .tag(unit)
                }
            }
            .pickerStyle(.segmented)
            if pickerValue == .custom {
                TextField("Units", text: $textValue, prompt: Text("e.g. cups"))
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
        }
        .listRowSeparator(.hidden)
        .onChange(of: pickerValue) { newValue in
            if newValue != .custom {
                units = newValue.rawValue
            }
        }
        .onChange(of: textValue) { newValue in
            units = newValue
        }
        .task {
            initializePicker()
        }
    }

    private func initializePicker() {
        if let startOption = UnitPickerOptions(rawValue: units) {
            pickerValue = startOption
        } else {
            pickerValue = UnitPickerOptions.custom
            textValue = units
        }
    }
}

#Preview {
    NavigationStack {
        List {
            UnitsPicker(units: .constant(""))
        }
    }
}
