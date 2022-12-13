import SwiftUI

struct UnitsPicker: View {

    @Binding var units: String?
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
                TextField("Units", text: $textValue, prompt: Text("e.g. cup"))
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
        guard let unitsUnwrap = units else {
            pickerValue = UnitPickerOptions.custom
            return
        }
        if let startOption = UnitPickerOptions(rawValue: unitsUnwrap) {
            pickerValue = startOption
        } else {
            pickerValue = UnitPickerOptions.custom
            if !unitsUnwrap.isEmpty {
                textValue = unitsUnwrap
            }
        }
    }
}

struct UnitsPickerSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                UnitsPicker(units: .constant(""))
            }
        }
    }
}
