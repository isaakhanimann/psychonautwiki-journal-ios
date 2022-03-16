import SwiftUI

struct UnitsPicker: View {

    @Binding var units: String?
    @State private var pickerValue = UnitPickerOptions.mg
    @State private var textValue = ""

    private enum UnitPickerOptions: String, CaseIterable {
        // swiftlint:disable identifier_name
        case g, mg, μg, mL, custom
    }

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
                TextField("Units", text: $textValue)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
        }
        .onChange(of: pickerValue) { newValue in
            if newValue != .custom {
                units = newValue.rawValue
            }
        }
        .onChange(of: textValue) { newValue in
            units = newValue
        }
        .task {
            units = UnitPickerOptions.mg.rawValue
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
